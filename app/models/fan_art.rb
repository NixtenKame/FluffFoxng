# frozen_string_literal: true

class FanArt < ApplicationRecord
  validates :title, :image_url, :artist_name, presence: true
  validates :image_url, format: { with: %r{\Ahttps?://}, message: "must start with http:// or https://" }
  validates :featured, inclusion: { in: [true, false] }

  scope :featured, -> { where(featured: true) }
  scope :ordered, -> { order(featured: :desc, created_at: :desc) }
end
