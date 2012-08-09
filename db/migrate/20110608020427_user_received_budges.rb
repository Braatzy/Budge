class UserReceivedBudges < ActiveRecord::Migration
  def self.up
    add_column :users, :num_user_budges, :integer, :default => 0
  end

  def self.down
    remove_column :users, :num_user_budges
  end
end
