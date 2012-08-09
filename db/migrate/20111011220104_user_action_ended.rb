class UserActionEnded < ActiveRecord::Migration
  def self.up
    add_column :user_actions, :ended_early, :boolean, :default => false
  end

  def self.down
    remove_column :user_actions, :ended_early
  end
end
