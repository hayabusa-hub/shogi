class AddDisplayToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :display, :string 
  end
end
