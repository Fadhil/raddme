class AddUniqueFriendTokenToUser < ActiveRecord::Migration
  def up
    add_column :users, :unique_friend_token, :integer
    add_index :users, [:unique_friend_token], unique: true
  end

  def down
    remove_column :users, :unique_friend_token
    remove_index :users, column: :unique_friend_token
  end 
end
