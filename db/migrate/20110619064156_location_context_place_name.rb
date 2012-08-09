class LocationContextPlaceName < ActiveRecord::Migration
  def self.up
    add_column :location_contexts, :place_name, :string
    add_column :budge_requests, :place_name, :string
  end

  def self.down
    remove_column :location_contexts, :place_name
    remove_column :budge_requests, :place_name
  end
end
