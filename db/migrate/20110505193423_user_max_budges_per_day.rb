class UserMaxBudgesPerDay < ActiveRecord::Migration
  def self.up
    add_column :users, :max_sent_budges_per_day, :integer, :default => 3
  end

  def self.down
    remove_column :users, :max_sent_budges_per_day
  end
end
