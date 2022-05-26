class AddColumnDisconnectTimeToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :disconnect_time, :integer, default: 0
  end
end
