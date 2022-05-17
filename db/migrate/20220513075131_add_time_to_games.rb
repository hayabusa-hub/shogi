class AddTimeToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :first_have_time, :integer, default: 0
    add_column :games, :second_have_time, :integer, default: 0
  end
end
