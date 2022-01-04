class AddKingPosToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :first_king_pos, :integer, default: 74
    add_column :games, :second_king_pos, :integer, default: 4
  end
end
