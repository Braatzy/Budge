class ProgramVictoryMessage < ActiveRecord::Migration
  def self.up
    add_column :programs, :completion_message, :text
    add_column :programs, :victory_message, :text
  end

  def self.down
    remove_column :programs, :completion_message
    remove_column :programs, :victory_message
  end
end
