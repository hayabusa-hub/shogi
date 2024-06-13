class AddToGamesErrorMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :error_message, :string
  end
end
