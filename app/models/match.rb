class Match < ApplicationRecord
  validates :user_id, presence: true,
                      uniqueness: true
end
