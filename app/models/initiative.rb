# frozen_string_literal: true

class Initiative < ApplicationRecord
  include Diaspora::Federated::Base
  #include Diaspora::Fields::Guid

  def update_initiative(params)
    if initiative.update(params)
      deliver_initiative_update
      true
    else
      false
    end
  end
  def deliver_initiative_update(opts={})  
    logger.debug self
    profile = Profile.find_by(carto_id: self.author)
    logger.debug profile
    #Defer l'action si on retrouve le propriétaire de la fiche
    if profile && profile.id
      author = User.find_by(id: profile.person_id)
      logger.debug author
      Diaspora::Federation::Dispatcher.defer_dispatch(author, self, opts)
    else      
      logger.error "No author found for initiative"
    end
  end
end
