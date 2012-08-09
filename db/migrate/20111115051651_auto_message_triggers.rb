class AutoMessageTriggers < ActiveRecord::Migration
  def self.up
    add_column :auto_messages, :trigger_trait_id, :integer
    add_column :auto_messages, :trigger_temperature_max, :integer
    add_column :auto_messages, :trigger_temperature_min, :integer
    add_column :auto_messages, :trigger_weather_conditions, :string
  end

  def self.down
    remove_column :auto_messages, :trigger_trait_id
    remove_column :auto_messages, :trigger_temperature_max
    remove_column :auto_messages, :trigger_temperature_min
    remove_column :auto_messages, :trigger_weather_conditions
  end
end
