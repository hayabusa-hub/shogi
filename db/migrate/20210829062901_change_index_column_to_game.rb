class ChangeIndexColumnToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :turn_board, :text
    remove_column :games, :opp_board, :text
  end
end
