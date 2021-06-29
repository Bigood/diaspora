class AddCartotalentsToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :carto_latitude, :string
    add_column :profiles, :carto_longitude, :string
    add_column :profiles, :carto_etablissement, :string, :limit => 1024
    add_column :profiles, :carto_user_type, :string
    add_column :profiles, :carto_technics, :string, :limit => 2048
    add_column :profiles, :carto_activites, :string, :limit => 2048
    add_column :profiles, :carto_methods, :string, :limit => 2048
    add_column :profiles, :carto_id, :string
  end
end
