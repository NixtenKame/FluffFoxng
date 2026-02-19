# frozen_string_literal: true

class AddTwoFactorToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :otp_enabled_at, :datetime
    add_column :users, :otp_backup_codes, :text
    add_column :users, :otp_required_for_login, :boolean, default: false, null: false
  end
end
