class PlayerMessageCheckin < ActiveRecord::Migration
  def self.up
    add_column :player_messages, :checkin_id, :integer
    add_column :player_messages, :message_type, :integer, :default => 0
  end

  def self.down
    remove_column :player_messages, :checkin_id
    remove_column :player_messages, :message_type
  end
end
