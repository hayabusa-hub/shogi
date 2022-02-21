class Match < ApplicationRecord
  
  # relationship
  belongs_to :user
  belongs_to :game, optional: true
  
  # validation
  validates :user_id, presence: true,
                      uniqueness: true
  
  def template
    ApplicationController.renderer.render partial: 'matchs/match', locals: { message: self }
  end
end
