class UserMaxLiveBudges < ActiveRecord::Migration
  def self.up
    add_column :users, :total_level_ups, :integer, :default => 0
    add_column :users, :meta_level, :integer, :default => 0
    add_column :users, :max_budges, :integer, :default => 1
    add_column :users, :num_given_budges, :integer, :default => 0
    add_column :users, :num_given_budges_completed, :integer, :default => 0
  end

  def self.down
    remove_column :users, :total_level_ups
    remove_column :users, :meta_level
    remove_column :users, :max_budges
    remove_column :users, :num_given_budges
    remove_column :users, :num_given_budges_completed
  end
end
