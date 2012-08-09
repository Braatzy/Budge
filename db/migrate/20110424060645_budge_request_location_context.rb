class BudgeRequestLocationContext < ActiveRecord::Migration
  def self.up
    add_column :budge_requests, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :budge_requests, :longitude, :decimal, :precision => 15, :scale => 10
    add_column :budge_requests, :metro_score, :integer, :default => 0
    add_column :budge_requests, :temperature_f, :integer
    add_column :budge_requests, :weather_conditions, :string
    add_column :budge_requests, :simplegeo_context, :text
  end

  def self.down
    remove_column :budge_requests, :latitude
    remove_column :budge_requests, :longitude
    remove_column :budge_requests, :metro_score
    remove_column :budge_requests, :temperature_f
    remove_column :budge_requests, :weather_conditions
    remove_column :budge_requests, :simplegeo_context
  end
end
