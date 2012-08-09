class ProgramPlayerProgramCoach < ActiveRecord::Migration
  def self.up
    add_column :program_players, :program_coach_id, :integer
  end

  def self.down
    remove_column :program_players, :program_coach_id
  end
end
