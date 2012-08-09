class LocationContextFoursquareContext < ActiveRecord::Migration
  def self.up
    add_column :location_contexts, :foursquare_context, :text  
    add_column :location_contexts, :foursquare_guess, :boolean, :default => false
  end

  def self.down
    remove_column :location_contexts, :foursquare_context
    remove_column :location_contexts, :foursquare_guess
  end
end
