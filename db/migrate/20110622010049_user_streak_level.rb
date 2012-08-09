class UserStreakLevel < ActiveRecord::Migration
  def self.up
    add_column :users, :streak_level, :integer, :default => 0
  end

  def self.down
    remove_column :users, :streak_level
  end
end
