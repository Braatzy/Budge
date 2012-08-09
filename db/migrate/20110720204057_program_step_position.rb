class ProgramStepPosition < ActiveRecord::Migration
  def self.up
    change_column :program_steps, :position, :integer, :null => false, :default => 1000
  end

  def self.down
    change_column :program_steps, :position, :integer, :null => true, :default => 1000
  end
end
