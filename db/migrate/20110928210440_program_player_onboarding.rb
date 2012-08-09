class ProgramPlayerOnboarding < ActiveRecord::Migration
  def self.up
    add_column :program_players, :onboarding_complete, :boolean, :default => false
    add_column :program_players, :start_date, :date
  end

  def self.down
    remove_column :program_players, :onboarding_complete
    remove_column :program_players, :start_date
  end
end
