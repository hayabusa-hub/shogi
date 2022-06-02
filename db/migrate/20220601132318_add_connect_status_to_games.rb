class AddConnectStatusToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :connect, :integer, default: 0
  end
end
