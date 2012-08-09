class CheckinSomeoneLeveledUp < ActiveRecord::Migration
  def self.up
    add_column :checkins, :budgee_leveled_up, :boolean, :default => false
    add_column :checkins, :budger_leveled_up, :boolean, :default => false
  end

  def self.down
    remove_column :checkins, :budgee_leveled_up
    remove_column :checkins, :budger_leveled_up
  end
end
