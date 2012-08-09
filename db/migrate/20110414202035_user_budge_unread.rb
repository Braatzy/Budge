class UserBudgeUnread < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :unread, :boolean, :default => true
    add_column :user_budges, :completed, :boolean, :default => false
    add_column :user_budges, :ignored, :boolean, :default => false
  end

  def self.down
    remove_column :user_budges, :unread
    remove_column :user_budges, :completed
    remove_column :user_budges, :ignored
  end
end
