class AddUserNameToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :first_user_name, :string
    add_column :games, :second_user_name, :string
    remove_column :games, :first_user_id, :integer
    remove_column :games, :second_user_id, :integer
  end
end
