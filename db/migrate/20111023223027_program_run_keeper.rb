class ProgramRunKeeper < ActiveRecord::Migration
  def self.up
    add_column :programs, :require_runkeeper, :boolean, :default => false
  end

  def self.down
    remove_column :programs, :require_runkeeper
  end
end
