class BudgeRefactorPartTwo < ActiveRecord::Migration
  def self.up
    rename_column :user_actions, :budger_user_id, :coach_user_id
    rename_column :user_actions, :system_budge, :templated_action
    
    # Program Players
    remove_column :program_players, :num_failed
    remove_column :program_players, :num_partial
    remove_column :program_players, :num_success
    remove_column :program_players, :num_skipped
    
    rename_column :program_players, :num_snooze, :num_snoozes
    
    # Programs
    remove_column :programs, :num_incomplete
    remove_column :programs, :num_lost
    remove_column :programs, :num_dropped_out
    
    rename_column :programs, :num_snoozed, :num_snoozing
    
    # User Actions
    add_column :user_actions, :skipped, :boolean, :default => false
    add_column :user_actions, :started, :boolean, :default => false
  end

  def self.down
    rename_column :user_actions, :coach_user_id, :budger_user_id
    rename_column :user_actions, :templated_action, :system_budge

    # Program Players
    add_column :program_players, :num_failed, :integer, :default => 0
    add_column :program_players, :num_partial, :integer, :default => 0
    add_column :program_players, :num_success, :integer, :default => 0
    add_column :program_players, :num_skipped, :integer, :default => 0
    
    rename_column :program_players, :num_snoozes, :num_snooze
    
    # Programs
    add_column :programs, :num_incomplete, :integer, :default => 0
    add_column :programs, :num_lost, :integer, :default => 0
    add_column :programs, :num_dropped_out, :integer, :default => 0
    
    rename_column :programs, :num_snoozing, :num_snoozed
    
    # User Actions
    remove_column :user_actions, :skipped
    remove_column :user_actions, :started

  end
end
