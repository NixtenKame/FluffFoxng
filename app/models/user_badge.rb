# frozen_string_literal: true

class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge
  belongs_to :creator, class_name: "User"

  validates :user_id, uniqueness: { scope: :badge_id }
end
