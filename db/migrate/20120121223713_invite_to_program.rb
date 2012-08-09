class InviteToProgram < ActiveRecord::Migration
  def self.up
    add_column :program_players, :num_invites_awarded, :integer, :default => 1
    add_column :program_players, :num_invites_sent, :integer, :default => 0
    add_column :program_players, :num_invites_viewed, :integer, :default => 0
    add_column :program_players, :num_invites_accepted, :integer, :default => 0
    remove_column :invitations, :dollars_credit
    add_column :invitations, :message, :text
  end

  def self.down
    remove_column :program_players, :num_invites_awarded
    remove_column :program_players, :num_invites_sent
    remove_column :program_players, :num_invites_viewed
    remove_column :program_players, :num_invites_accepted
    add_column :invitations, :dollars_credit, :decimal, :precision => 8, :scale => 2
    remove_column :invitations, :message
  end
end
