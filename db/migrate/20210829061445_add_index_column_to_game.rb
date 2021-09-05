class AddIndexColumnToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :opp_board, :text
    add_column :games, :own_piece, :text
  end
end
