class PlayerMessageEntryId < ActiveRecord::Migration
  def self.up
    add_column :player_messages, :entry_id, :integer
    add_column :programs, :last_level, :integer, :default => 0
  end

  def self.down
    remove_column :player_messages, :entry_id
    remove_column :programs, :last_level
  end
end
