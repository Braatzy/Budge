class PlayerMessageContextTriggers < ActiveRecord::Migration
  def self.up
    remove_column :player_messages, :context_trigger
    remove_column :player_messages, :has_context_trigger
    add_column :player_messages, :trigger_trait_id, :integer
    add_column :player_messages, :trigger_temperature_max, :integer
    add_column :player_messages, :trigger_temperature_min, :integer
    add_column :player_messages, :trigger_weather_conditions, :string
  end

  def self.down
    add_column :player_messages, :context_trigger, :integer
    add_column :player_messages, :has_context_trigger, :boolean, :default => false
    remove_column :player_messages, :trigger_trait_id
    remove_column :player_messages, :trigger_temperature_max
    remove_column :player_messages, :trigger_temperature_min
    remove_column :player_messages, :trigger_weather_conditions
  end
end
