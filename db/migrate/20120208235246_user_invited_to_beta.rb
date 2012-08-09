class UserInvitedToBeta < ActiveRecord::Migration
  def self.up
    add_column :users, :invited_to_beta, :boolean, :default => false
    User.update_all(['invited_to_beta = ?', true], ['in_beta = ?', true])
    User.update_all(['invited_to_beta = ?', false], ['in_beta = ?', false])
  end

  def self.down
    remove_column :users, :invited_to_beta
  end
end
