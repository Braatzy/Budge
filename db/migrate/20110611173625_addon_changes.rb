class AddonChanges < ActiveRecord::Migration
  def self.up
    remove_column :addons, :auto_unlocked
    add_column :addons, :auto_unlocked_at_level, :integer
  end

  def self.down
    remove_column :addons, :auto_unlocked_at_level
    add_column :addons, :auto_unlocked, :boolean, :default => false
  end
end
