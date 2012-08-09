class UserNotificationSettings < ActiveRecord::Migration
  def self.up
    add_column :users, :create_next_notification, :datetime
    add_column :users, :notification_streak, :integer, :default => 0
  end

  def self.down
    remove_column :users, :create_next_notification
    remove_column :users, :notification_streak
  end
end
