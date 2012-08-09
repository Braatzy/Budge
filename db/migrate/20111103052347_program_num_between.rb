class ProgramNumBetween < ActiveRecord::Migration
  def self.up
    add_column :programs, :num_scheduled, :integer, :default => 0
    add_column :programs, :num_budgeless, :integer, :default => 0
  end

  def self.down
    remove_column :programs, :num_scheduled
    remove_column :programs, :num_budgeless
  end
end
