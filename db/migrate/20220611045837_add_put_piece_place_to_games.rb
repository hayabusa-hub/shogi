class AddPutPiecePlaceToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :latest_place, :integer, default: -1
    add_column :games, :second_latest_place, :integer, default: -1
  end
end
