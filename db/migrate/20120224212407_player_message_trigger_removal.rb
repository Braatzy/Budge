class PlayerMessageTriggerRemoval < ActiveRecord::Migration
  def up
    remove_column :player_messages, :trigger_temperature_max
    remove_column :player_messages, :trigger_temperature_min
    remove_column :player_messages, :trigger_weather_conditions
  end

  def down
    add_column :player_messages, :trigger_temperature_max, :integer
    add_column :player_messages, :trigger_temperature_min, :integer
    add_column :player_messages, :trigger_weather_conditions, :string
  end
end
