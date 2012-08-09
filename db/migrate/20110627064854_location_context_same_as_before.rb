class LocationContextSameAsBefore < ActiveRecord::Migration
  def self.up
    add_column :location_contexts, :possible_duplicate, :boolean, :default => false
  end

  def self.down
    remove_column :location_contexts, :possible_duplicate
  end
end
