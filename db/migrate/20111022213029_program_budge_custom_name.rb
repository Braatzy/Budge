class ProgramBudgeCustomName < ActiveRecord::Migration
  def self.up
    add_column :program_action_templates, :wording, :string
  end

  def self.down
    remove_column :program_action_templates, :wording
  end
end
