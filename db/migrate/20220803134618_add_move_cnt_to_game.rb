class AddMoveCntToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :move_cnt, :integer, default: 0
  end
end
