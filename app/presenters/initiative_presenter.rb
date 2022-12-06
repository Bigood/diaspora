# frozen_string_literal: true

class InitiativePresenter < BasePresenter
  def as_json
    base_api_json
  end

  private

  def base_api_json
    {
      author: author,
      name:        name,
      carto_id:          carto_id,
    }.compact
  end

end
