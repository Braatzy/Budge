class ProgramPlayerUpdate < ActiveRecord::Migration
  def self.up
    add_column :program_steps, :level, :integer
    add_column :program_steps, :start_message, :text
    
    add_column :program_players, :level, :integer, :default => 1
    add_column :program_players, :max_level, :integer, :default => 1
    
    add_column :player_steps, :num_times_played, :integer, :default => 1
  end

  def self.down
    remove_column :program_steps, :level
    remove_column :program_steps, :start_message
    
    remove_column :program_players, :level
    remove_column :program_players, :max_level
    
    remove_column :player_steps, :num_times_played
  end
end
