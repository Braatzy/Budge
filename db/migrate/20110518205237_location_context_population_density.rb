class LocationContextPopulationDensity < ActiveRecord::Migration
  def self.up
    rename_column :location_contexts, :metro_score, :population_density
  end

  def self.down
    rename_column :location_contexts, :population_density, :metro_score
  end
end
