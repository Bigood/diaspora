# frozen_string_literal: true

module Api
  module V1
    class InitiativesController < Api::V1::BaseController      
      # For account creation, skip CSRF token
      skip_before_action :verify_authenticity_token


      def all
        initiatives = []
        Initiative.find_each do |initiative|
          initiatives.push(InitiativePresenter.new(initiative).as_json)
        end
        render json: initiatives
      end

      def find_by_id
        logger.debug params
        initiative = Initiative.find_by(carto_id: params[:carto_id])
        logger.debug initiative 
        render json: InitiativePresenter.new(initiative).as_json
      end

      def create
        create_params = params.permit(:carto_id, :author, :name).to_h || {}

        initiative = Initiative.create(create_params)
        
        if !initiative
          logger.error initiative.errors
          render_error 422, "Failed to create initiative"
        else
          #https://stackoverflow.com/questions/44746982/what-does-sign-in-of-devise-do
          
          # Envoi des infos quand même à tous les pods connectés via initiative.deliver_profile_update(), voir models/initiative#389
          initiative.deliver_initiative_update()
          render json: initiative
        end
      end

      def update
        params_to_update =  params.permit(:author, :name).to_h || {}
        
        logger.debug params
        initiative = Initiative.find_by(carto_id: params[:carto_id])
        logger.debug initiative 

        if initiative.nil?
          return render_error 404, "Initiative not found"
        end
        is_saved = initiative.update(params_to_update)

        if is_saved
          render json: InitiativePresenter.new(initiative).as_json
        else
          render_error 422, "Failed to update the initiative settings"
        end
      end

      def delete        
        logger.debug params
        initiative = Initiative.find_by(carto_id: params[:carto_id])
        logger.debug initiative 

        if initiative.nil?
          return render_error 404, "Initiative not found" 
        end
        
        initiative.destroy
        
        head :ok, content_type: "text/html"
        
      end
    end
  end
end
