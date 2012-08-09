class ProgramPlayerNeedsToPlayAt < ActiveRecord::Migration
  def self.up
    add_column :program_players, :needs_to_play_at, :datetime
  end

  def self.down
    remove_column :program_players, :needs_to_play_at
  end
end
