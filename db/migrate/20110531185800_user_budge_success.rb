class UserBudgeSuccess < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :successful, :boolean, :default => false
    rename_column :checkins, :was_desired, :desired_outcome
  end

  def self.down
    remove_column :user_budges, :successful
    rename_column :checkins, :desired_outcome, :was_desired
  end
end
