class PlayerMessageToFields < ActiveRecord::Migration
  def self.up
    add_column :player_messages, :to_player, :boolean, :default => false
    add_column :player_messages, :to_supporters, :boolean, :default => false

    PlayerMessage.update_all(['to_player = ?', true], ['from_coach = ?', true])
  end

  def self.down
    remove_column :player_messages, :to_player
    remove_column :player_messages, :to_supporters
  end
end
