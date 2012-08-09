class ProgramPlayerCoaches < ActiveRecord::Migration
  def self.up
    add_column :program_players, :coach_data, :text
  end

  def self.down
    remove_column :program_players, :coach_data
  end
end
