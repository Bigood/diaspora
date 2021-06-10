# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      include TagsHelper
      
      # For account creation, skip CSRF token
      skip_before_action :verify_authenticity_token

      before_action except: %i[contacts update show all create] do
        require_access_token %w[public:read]
      end

      before_action only: %i[update] do
        require_access_token %w[profile:modify]
      end

      before_action only: %i[contacts] do
        require_access_token %w[contacts:read]
      end

      before_action only: %i[block] do
        require_access_token %w[contacts:modify]
      end

      before_action only: %i[show] do
        require_access_token %w[profile]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error 404, "User not found"
      end

      def all
        users = []
        Person.find_each do |person|
          users.push(PersonPresenter.new(person).carto_as_json)
        end
        render json: users
      end

      def show
        person = if params.has_key?(:id)
          found_person = Person.find_by!(guid: params[:id])
          raise ActiveRecord::RecordNotFound unless found_person.searchable || access_token?("contacts:read")

          found_person
        else
          current_user.person
        end
        render json: PersonPresenter.new(person, current_user).profile_hash_as_api_json
      end

      def create
        # ActionController::Parameters.permit_all_parameters
        # params_to_update = ActionController::Parameters.new(params)
        signup_params = params.permit(:email, :username, :password, :password_confirmation, :person).to_h || {}
        # log.debug signup_params
        # Create user and person
        user = User.build(signup_params)
        
        # Récupération des paramètres de profil autorisés
        params_to_update = profile_update_params

        user.update_profile(params_to_update)

        sign_in(user)
        render json: user
      end

      def update
        params_to_update = profile_update_params
        if params_to_update && current_user.update_profile(params_to_update)
          render json: PersonPresenter.new(current_user.person, current_user).profile_hash_as_api_json
        else
          render_error 422, "Failed to update the user settings"
        end
      rescue RuntimeError
        render_error 422, "Failed to update the user settings"
      end

      def contacts
        if params.require(:user_id) != current_user.guid
          render_error 404, "User not found"
          return
        end

        contacts_query = aspects_service.all_contacts
        contacts_page = index_pager(contacts_query).response
        contacts_page[:data] = contacts_page[:data].map {|c| PersonPresenter.new(c.person).as_api_json }
        render_paged_api_response contacts_page
      end

      def photos
        person = Person.find_by!(guid: params[:user_id])
        user_for_query = current_user if private_read?
        photos_query = Photo.visible(user_for_query, person, :all, Time.current)
        photos_page = time_pager(photos_query).response
        photos_page[:data] = photos_page[:data].map {|photo| PhotoPresenter.new(photo).as_api_json(true) }
        render_paged_api_response photos_page
      end

      def posts
        person = Person.find_by!(guid: params[:user_id])
        posts_query = if private_read?
                        current_user.posts_from(person, false)
                      else
                        Post.where(author_id: person.id, public: true)
                      end
        posts_page = time_pager(posts_query).response
        posts_page[:data] = posts_page[:data].map {|post| PostPresenter.new(post, current_user).as_api_response }
        render_paged_api_response posts_page
      end

      def block
        person = Person.find_by!(guid: params[:user_id])
        service = BlockService.new(current_user)
        if request.request_method_symbol == :post
          begin
            service.block(person)
            head :created
          rescue ActiveRecord::RecordNotUnique
            render_error 409, "User is already blocked"
          end
        elsif request.request_method_symbol == :delete
          begin
            service.unblock(person)
            head :no_content
          rescue ActiveRecord::RecordNotFound
            render_error 410, "User is not blocked"
          end
        else
          raise AbstractController::ActionNotFound
        end
      end

      private

      def aspects_service
        @aspects_service ||= AspectsMembershipService.new(current_user)
      end

      def profile_update_params
        raise RuntimeError if params.has_key?(:id)

        updates = params.permit(:bio, :birthday, :gender, :location, :name,
                                :searchable, :show_profile_info, :nsfw, :tags,
                                :carto_latitude, :carto_longitude, :carto_etablissement, :carto_user_type, :carto_technics, :carto_activites, :carto_methods).to_h || {}
        if updates.has_key?(:name)
          updates[:first_name] = updates[:name]
          updates[:last_name] = nil
          updates.delete(:name)
        end
        if updates.has_key?(:show_profile_info)
          updates[:public_details] = updates[:show_profile_info]
          updates.delete(:show_profile_info)
        end
        process_tags_updates(updates)
        updates
      end

      def process_tags_updates(updates)
        return unless params.has_key?(:tags)

        raise RuntimeError if params[:tags].length > Profile::MAX_TAGS

        tags = params[:tags].map {|tag| "#" + normalize_tag_name(tag) }.join(" ")
        updates[:tag_string] = tags
        updates.delete(:tags)
      end
    end
  end
end
