class Match < ApplicationRecord
  
  # relationship
  belongs_to :user
  
  # validation
  validates :user_id, presence: true,
                      uniqueness: true
end
