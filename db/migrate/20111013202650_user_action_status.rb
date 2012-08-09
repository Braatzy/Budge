class UserActionStatus < ActiveRecord::Migration
  def self.up
    add_column :user_actions, :status, :integer, :default => 0
    remove_column :user_actions, :completed
    remove_column :user_actions, :successful
    remove_column :user_actions, :skipped
    remove_column :user_actions, :started
    remove_column :user_actions, :ended_early
  end

  def self.down
    remove_column :user_actions, :status
    add_column :user_actions, :completed, :boolean, :default => false
    add_column :user_actions, :successful, :boolean, :default => false
    add_column :user_actions, :skipped, :boolean, :default => false
    add_column :user_actions, :started, :boolean, :default => false
    add_column :user_actions, :ended_early, :boolean, :default => false
  end
end
