class AddIndexToMatchesUserId < ActiveRecord::Migration[6.0]
  def change
    add_index :matches, :user_id, unique: true
  end
end
