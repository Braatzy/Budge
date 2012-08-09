class SeductiveOnboarding < ActiveRecord::Migration
  def self.up
    add_column :programs, :onboarding_task, :string
    add_column :program_budges, :available_during_placement, :boolean, :default => false
    add_column :users, :nag_mode, :boolean, :default => false
    
    ProgramBudge.update_all(:available_during_placement => false)
  end

  def self.down
    remove_column :programs, :onboarding_task
    remove_column :program_budges, :available_during_placement
    remove_column :users, :nag_mode
  end
end
