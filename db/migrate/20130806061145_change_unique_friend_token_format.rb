class ChangeUniqueFriendTokenFormat < ActiveRecord::Migration
  def up
    change_column :users, :unique_friend_token, :string
  end

  def down
    change_column :users, :unique_friend_token, :integer
  end
end
