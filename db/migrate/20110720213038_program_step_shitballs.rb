class ProgramStepShitballs < ActiveRecord::Migration
  def self.up
    remove_column :program_steps, :program_id
    add_column :program_steps, :program_id, :integer
    remove_column :program_steps, :progress
    add_column :program_steps, :progress, :integer, :default => 0
  end

  def self.down
    remove_column :program_steps, :program_id
    add_column :program_steps, :program_id, :string
    remove_column :program_steps, :progress
    add_column :program_steps, :progress, :string
  end
end
