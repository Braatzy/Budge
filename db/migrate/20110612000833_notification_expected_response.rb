class NotificationExpectedResponse < ActiveRecord::Migration
  def self.up
    add_column :notifications, :expected_response, :boolean, :default => false
  end

  def self.down
    remove_column :notifications, :expected_response
  end
end
