class PlayerMessageDeliverVia < ActiveRecord::Migration
  def self.up
    remove_column :player_messages, :delivered_via
    add_column :player_messages, :delivered_via, :integer, :default => 0

    add_column :player_messages, :deliver_via_pref, :integer
    remove_column :player_messages, :private
  end

  def self.down
    remove_column :player_messages, :delivered_via
    add_column :player_messages, :delivered_via, :string
    remove_column :player_message, :deliver_via_pref
    add_column :player_messages, :private, :boolean, :default => false
  end
end
