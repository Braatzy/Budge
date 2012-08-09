class StepNicknames < ActiveRecord::Migration
  def self.up
    add_column :program_steps, :name, :string
  end

  def self.down
    remove_column :program_steps, :name
  end
end
