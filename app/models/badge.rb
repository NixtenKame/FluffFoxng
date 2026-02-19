# frozen_string_literal: true

class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  before_validation :normalize_color

  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/ }

  private

  def normalize_color
    raw = color.to_s.strip
    raw = "5B8DEF" if raw.blank?
    raw = raw.delete_prefix("#")
    self.color = "##{raw.upcase}"
  end
end
