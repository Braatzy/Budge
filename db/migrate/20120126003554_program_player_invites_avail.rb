class ProgramPlayerInvitesAvail < ActiveRecord::Migration
  def self.up
    remove_column :program_players, :num_invites_awarded
    add_column :program_players, :num_invites_available, :integer, :default => 1
    
    ProgramPlayer.update_all(:num_invites_available => 1)
  end

  def self.down
    add_column :program_players, :num_invites_awarded, :integer, :default => 1
    remove_column :program_players, :num_invites_available
  end
end
