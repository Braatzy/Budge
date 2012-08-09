class ProgramPlayerSupporterInvite < ActiveRecord::Migration
  def self.up
    add_column :program_players, :num_supporter_invites, :integer, :default => 1
    ProgramPlayer.update_all(['num_supporter_invites = ?', 1])
  end

  def self.down
    remove_column :program_players, :num_supporter_invites
  end
end
