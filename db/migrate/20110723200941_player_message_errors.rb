class PlayerMessageErrors < ActiveRecord::Migration
  def self.up
    add_column :player_messages, :error, :string
    add_column :player_messages, :send_attempts, :integer, :default => 0
  end

  def self.down
    remove_column :player_messages, :error
    remove_column :player_messages, :send_attempts
  end
end
