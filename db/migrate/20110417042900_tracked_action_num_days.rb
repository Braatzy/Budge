class TrackedActionNumDays < ActiveRecord::Migration
  def self.up
    add_column :tracked_actions, :num_days_this_week, :integer, :default => 0
    add_column :tracked_actions, :num_days_this_month, :integer, :default => 0
  end

  def self.down
    remove_column :tracked_actions, :num_days_this_week
    remove_column :tracked_actions, :num_days_this_month
  end
end
