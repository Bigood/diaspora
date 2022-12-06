# frozen_string_literal: true

class AddInitiativeCarto < ActiveRecord::Migration[5.2]
  def up
    create_table :initiatives do |t|
      t.string   :author
      t.string  :carto_id
      t.string  :name
      t.datetime :updated_at
    end
    add_index :initiatives, :carto_id, name: :index_initiatives_on_carto_id
  end
end
