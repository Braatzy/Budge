class CreateProgramBudgeTemplates < ActiveRecord::Migration
  def self.up
    create_table :program_budge_templates do |t|
      t.integer :program_id
      t.integer :program_step_id
      t.integer :position, :default => 1000
      t.integer :trait_id
      t.string  :name
      t.integer :alignment
      t.boolean :do
      t.string  :duration
      t.string  :completion_requirement_type
      t.string  :completion_requirement_number
      t.string  :custom_text

      t.timestamps
    end
  end

  def self.down
    drop_table :program_budge_templates
  end
end
