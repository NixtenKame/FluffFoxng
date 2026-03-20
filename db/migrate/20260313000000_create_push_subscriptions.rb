# frozen_string_literal: true

class CreatePushSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :push_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.text :endpoint, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false
      t.datetime :expiration_time
      t.string :user_agent

      t.timestamps
    end

    add_index :push_subscriptions, %i[user_id endpoint], unique: true
  end
end
