class ProgramPlayerScoreData < ActiveRecord::Migration
  def self.up
    add_column :program_players, :score_data, :text
  end

  def self.down
    remove_column :program_players, :score_data
  end
end
