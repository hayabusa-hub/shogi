class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :first_user_id
      t.integer :second_user_id
      t.text :board

      t.timestamps
    end
  end
end
