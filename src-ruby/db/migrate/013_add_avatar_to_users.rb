class AddAvatarToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :avatar, :longblob, null: true
  end

  def self.down
    remove_column :users, :avatar
  end
end
