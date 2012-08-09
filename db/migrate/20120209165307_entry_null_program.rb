class EntryNullProgram < ActiveRecord::Migration
  def self.up
    change_column :entries, :program_id, :integer, :null => true
    change_column :entries, :program_player_id, :integer, :null => true
  end

  def self.down
    change_column :entries, :program_id, :integer, :null => false
    change_column :entries, :program_player_id, :integer, :null => false
  end
end
