class UserUsernames < ActiveRecord::Migration
  def self.up
    add_column :users, :phone, :string
    add_column :users, :phone_normalized, :string
    add_column :users, :phone_verified, :boolean, :default => false
    add_column :users, :facebook_username, :string
    add_column :users, :twitter_username, :string    
  end

  def self.down
    remove_column :users, :phone
    remove_column :users, :phone_normalized
    remove_column :users, :phone_verified
    remove_column :users, :facebook_username
    remove_column :users, :twitter_username
  end
end
