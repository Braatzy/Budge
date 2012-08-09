class ProgramCompleteOrVictorious < ActiveRecord::Migration
  def self.up
    add_column :program_players, :completed, :boolean, :default => false
    add_column :program_players, :victorious, :boolean, :default => false
  end

  def self.down
    remove_column :program_players, :completed
    remove_column :program_players, :victorious
  end
end
