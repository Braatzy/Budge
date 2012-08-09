class UserBudgeCompletionRequirements < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :success_requirement_type, :string
    add_column :user_budges, :success_requirement_number, :decimal, :precision => 20, :scale => 2
    add_column :user_budges, :duration, :integer, :default => 1
  end

  def self.down
    remove_column :user_budges, :success_requirement_type
    remove_column :user_budges, :success_requirement_number
    remove_column :user_budges, :duration, :integer
  end
end
