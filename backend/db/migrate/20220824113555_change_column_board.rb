class ChangeColumnBoard < ActiveRecord::Migration[6.0]
  def change
    remove_column :game_records, :board, :string
    add_column :game_records, :board, :text, default: ""
  end
end
