# frozen_string_literal: true

class AddProfileCustomStyleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :profile_custom_style, :text, default: "", null: false
  end
end
