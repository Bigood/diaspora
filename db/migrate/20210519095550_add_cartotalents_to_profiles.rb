class AddCartotalentsToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :carto_latitude, :float
    add_column :profiles, :carto_longitude, :float
    add_column :profiles, :carto_etablissement, :string
    add_column :profiles, :carto_user_type, :string
    add_column :profiles, :carto_technics, :integer
    add_column :profiles, :carto_activites, :integer
    add_column :profiles, :carto_methods, :integer
  end
end
