class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.integer :user_id,    unique: true
      t.integer :opponent_id, default: 0
      t.integer :status,     default: 0

      t.timestamps
    end
  end
end
