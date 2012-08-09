class ProgramPlayerNumMessages < ActiveRecord::Migration
  def self.up
    add_column :program_players, :num_messages_to_coach, :integer, :default => 0
    add_column :program_players, :num_messages_from_coach, :integer, :default => 0
  end

  def self.down
    remove_column :program_players, :num_messages_to_coach
    remove_column :program_players, :num_messages_from_coach
  end
end
