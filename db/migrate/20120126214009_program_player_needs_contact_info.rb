class ProgramPlayerNeedsContactInfo < ActiveRecord::Migration
  def self.up
    add_column :program_players, :needs_contact_info, :boolean, :default => true
    add_column :program_players, :hardcoded_reminder_hour, :integer
    
    ProgramPlayer.update_all(['needs_contact_info = ?', true])
    ProgramPlayer.update_all(['hardcoded_reminder_hour = ?', nil])
  end

  def self.down
    remove_column :program_players, :needs_contact_info
    remove_column :program_players, :hardcoded_reminder_hour
  end
end
