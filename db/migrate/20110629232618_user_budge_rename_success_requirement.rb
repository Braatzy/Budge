class UserBudgeRenameSuccessRequirement < ActiveRecord::Migration
  def self.up
    rename_column :user_budges, :success_requirement_number, :completion_requirement_number
    rename_column :user_budges, :success_requirement_type, :completion_requirement_type
  end

  def self.down
    rename_column :user_budges, :completion_requirement_number, :success_requirement_number
    rename_column :user_budges, :completion_requirement_type, :success_requirement_type
  end
end
