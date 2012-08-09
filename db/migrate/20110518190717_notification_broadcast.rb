class NotificationBroadcast < ActiveRecord::Migration
  def self.up
    remove_column :notifications, :streak
    remove_column :notifications, :notification_number
    add_column :notifications, :broadcast, :boolean, :default => false
    add_column :users, :streak, :integer, :default => 0
    rename_column :notifications, :for, :for_object
    change_column :notifications, :delivered_via, :string
    change_column :notifications, :message_style_token, :string
  end

  def self.down
    add_column :notifications, :streak, :integer, :default => 0
    add_column :notifications, :notification_number, :integer, :default => 0
    remove_column :notifications, :broadcast
    remove_column :users, :streak
    rename_column :notifications, :for_object, :for
    change_column :notifications, :delivered_via, :integer
    change_column :notifications, :message_style_token, :integer
  end
end
