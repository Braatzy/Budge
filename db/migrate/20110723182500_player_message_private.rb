class PlayerMessagePrivate < ActiveRecord::Migration
  def self.up
    add_column :player_messages, :private, :boolean, :default => false
    add_column :player_messages, :program_step_id, :integer
  end

  def self.down
    remove_column :player_messages, :private
    remove_column :player_messages, :program_step
  end
end
