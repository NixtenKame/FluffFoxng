# frozen_string_literal: true

class CreateBadgesAndUserBadges < ActiveRecord::Migration[7.2]
  def change
    create_table :badges do |t|
      t.string :name, null: false
      t.text :description
      t.string :color, null: false, default: "#5B8DEF"
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :badges, :name, unique: true

    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true
      t.bigint :creator_id, null: false
      t.timestamps
    end

    add_foreign_key :user_badges, :users, column: :creator_id
    add_index :user_badges, [:user_id, :badge_id], unique: true
    add_index :user_badges, :creator_id
  end
end
