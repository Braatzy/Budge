class ProgramPlayersActive < ActiveRecord::Migration
  def self.up
    add_column :program_players, :active, :boolean, :default => true
  end

  def self.down
    remove_column :program_players, :active
  end
end
