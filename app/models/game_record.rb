class GameRecord < ApplicationRecord
  
  #relationship
  belongs_to :game, optional: true
end
