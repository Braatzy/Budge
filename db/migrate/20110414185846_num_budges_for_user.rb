class NumBudgesForUser < ActiveRecord::Migration
  def self.up
    add_column :users, :num_live_budges, :integer, :default => 0
    add_column :users, :num_completed_budges, :integer, :default => 0
    add_column :users, :num_ignored_budges, :integer, :default => 0
  end

  def self.down
    remove_column :users, :num_live_budges
    remove_column :users, :num_completed_budges
    remove_column :users, :num_ignored_budges    
  end
end
