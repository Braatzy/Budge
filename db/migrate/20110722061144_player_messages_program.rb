class PlayerMessagesProgram < ActiveRecord::Migration
  def self.up
    add_column :player_messages, :program_id, :integer
  end

  def self.down
    remove_column :player_messages, :program_id, :integer
  end
end
