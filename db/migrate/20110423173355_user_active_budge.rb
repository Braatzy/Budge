class UserActiveBudge < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :accepted, :boolean, :default => false
    add_column :user_budges, :blocked, :boolean, :default => false
    rename_column :users, :max_budges, :max_accepted_budges
    rename_column :users, :num_live_budges, :num_accepted_budges
    add_column :users, :num_unaccepted_budges, :integer, :default => 0    
  end

  def self.down
    remove_column :user_budges, :accepted
    remove_column :user_budges, :blocked
    rename_column :users, :max_accepted_budges, :max_budges
    rename_column :users, :num_accepted_budges, :num_live_budges
    remove_column :users, :num_unaccepted_budges
  end
end
