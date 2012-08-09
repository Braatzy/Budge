class InvitationNotification < ActiveRecord::Migration
  def self.up
    add_column :invitations, :notification_id, :integer
  end

  def self.down
    remove_column :invitations, :notification_id
  end
end
