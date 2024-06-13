class CreateGameRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :game_records do |t|
      t.integer :game_id
      t.integer :cnt
      t.string :board
      t.boolean :isOute
      t.boolean :isFinish

      t.timestamps
    end
  end
end
