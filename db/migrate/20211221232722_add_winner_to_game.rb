class AddWinnerToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :winner, :integer, default: 0
    remove_column :games, :error_message, :string
  end
end
