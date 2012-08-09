class UserNumNotifications < ActiveRecord::Migration
  def self.up
    add_column :users, :num_notifications, :integer, :default => 0
  end

  def self.down
    remove_column :users, :num_notifications
  end
end
