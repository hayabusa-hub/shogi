class AddTurnToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :turn, :integer
  end
end
