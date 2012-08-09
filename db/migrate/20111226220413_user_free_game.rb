class UserFreeGame < ActiveRecord::Migration
  def self.up
    add_column :program_players, :needs_placement, :boolean, :default => true
    remove_column :users, :emergency_phone_normalized
    remove_column :users, :emergency_phone
    remove_column :users, :emergency_phone_verified
    ProgramPlayer.update_all(['needs_placement = ?', true], ['onboarding_complete = ?', false])
  end

  def self.down
    add_column :users, :emergency_phone_normalized, :string
    add_column :users, :emergency_phone, :string
    add_column :users, :emergency_phone_verified, :boolean, :default => false
    remove_column :program_players, :needs_placement
  end
end
