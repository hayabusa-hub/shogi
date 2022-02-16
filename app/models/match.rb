class Match < ApplicationRecord
  
  # relationship
  belongs_to :user
  
  # validation
  validates :user_id, presence: true,
                      uniqueness: true
  
  def template
    ApplicationController.renderer.render partial: 'matchs/match', locals: { message: self }
  end
end
