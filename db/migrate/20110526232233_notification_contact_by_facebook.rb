class NotificationContactByFacebook < ActiveRecord::Migration
  def self.up
    add_column :users, :contact_by_facebook_wall_pref, :decimal, :precision => 10, :scale => 8, :default => 5
    add_column :users, :contact_by_facebook_wall_score, :decimal, :precision => 10, :scale => 8, :default => 10
    add_column :users, :contact_by_friend_pref, :decimal, :precision => 10, :scale => 8, :default => 1
    add_column :users, :contact_by_friend_score, :decimal, :precision => 10, :scale => 8, :default => 10
  end

  def self.down
  end
end
