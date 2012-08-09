class InvitationProgramPlayer < ActiveRecord::Migration
  def self.up
    add_column :invitations, :program_player_id, :integer
  end

  def self.down
    remove_column :invitations, :program_player_id
  end
end
