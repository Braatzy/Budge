class AddLastCheckedInColumnToProgramPlayers < ActiveRecord::Migration
  def self.up
    add_column :program_players, :last_checked_in, :datetime
    ProgramPlayer.update_last_checked_in_for_all_players
  end

  def self.down
    remove_column :program_players, :last_checked_in
  end
end
