class ActionTemplateMinDayNumber < ActiveRecord::Migration
  def self.up
    add_column :program_action_templates, :min_day_number, :integer, :default => 0
    add_column :user_actions, :min_day_number, :integer, :default => 0
  end

  def self.down
    remove_column :program_action_templates, :min_day_number
    remove_column :user_actions, :min_day_number
  end
end
