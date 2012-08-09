class ProgramPlayerOnboardingFlags < ActiveRecord::Migration
  def self.up
    remove_column :program_players, :needs_placement
    add_column :program_players, :needs_coach_pitch, :boolean, :default => true
    add_column :program_players, :needs_survey_pitch, :boolean, :default => true
    
    ProgramPlayer.update_all(['needs_coach_pitch = ?, needs_survey_pitch = ?', true, true])
    ProgramPlayer.update_all(['needs_coach_pitch = ?, needs_survey_pitch = ?', false, false], ['onboarding_complete = ?', true])
  end

  def self.down
    add_column :program_players, :needs_placement, :boolean, :default => true
    remove_column :program_players, :needs_coach_pitch
    remove_column :program_players, :needs_survey_pitch
  end
end
