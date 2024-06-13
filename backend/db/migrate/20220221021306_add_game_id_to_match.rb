class AddGameIdToMatch < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :game_id, :integer, default: -1
  end
end
