class ChangeColumnToDisplayBoard < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :first_user_board, :integer
    add_column :games, :second_user_board, :integer
    remove_column :games, :display, :string
  end
end
