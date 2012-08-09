class UserAreasOfInterest < ActiveRecord::Migration
  def self.up
    add_column :users, :unlock_pack_credits, :integer, :default => 0

    add_column :users, :max_concurrent_behaviors, :integer, :default => 1
    add_column :users, :num_concurrent_behaviors, :integer, :default => 0
  end

  def self.down
    remove_column :users, :unlock_pack_credits
    remove_column :users, :max_concurrent_behaviors
    remove_column :users, :num_concurrent_behaviors
  end
end
