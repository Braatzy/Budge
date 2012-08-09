class ProgramPlayerCoachNote < ActiveRecord::Migration
  def self.up
    add_column :program_players, :coach_note, :string
  end

  def self.down
    remove_column :program_players, :coach_note
  end
end
