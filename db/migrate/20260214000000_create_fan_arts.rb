# frozen_string_literal: true

class CreateFanArts < ActiveRecord::Migration[8.0]
  def change
    create_table :fan_arts do |t|
      t.string :title, null: false
      t.string :image_url, null: false
      t.string :artist_name, null: false
      t.string :artist_url
      t.boolean :featured, default: false, null: false

      t.timestamps
    end

    add_index :fan_arts, :featured
    add_index :fan_arts, :created_at
  end
end
