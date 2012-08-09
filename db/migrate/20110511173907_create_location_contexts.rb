class CreateLocationContexts < ActiveRecord::Migration
  def self.up
    remove_column :budge_requests, :metro_score
    remove_column :budge_requests, :temperature_f
    remove_column :budge_requests, :weather_conditions
    remove_column :budge_requests, :simplegeo_context
    add_column :budge_requests, :foursquare_category_id, :string
    
    create_table :location_contexts do |t|
      t.integer :user_id
      t.string :context_about
      t.integer :context_id
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.integer :metro_score, :default => 0
      t.integer :temperature_f
      t.string :weather_conditions
      t.text :simplegeo_context
      t.string :foursquare_place_id
      t.string :foursquare_category_id
      t.string :foursquare_checkin_id

      t.timestamps
    end
    
    add_index :location_contexts, [:user_id]
    add_index :location_contexts, [:context_about, :context_id], :name => :context
  end

  def self.down
    drop_table :location_contexts
    add_column :budge_requests, :metro_score, :integer, :default => 0
    add_column :budge_requests, :temperature_f, :integer
    add_column :budge_requests, :weather_conditions, :string
    add_column :budge_requests, :simplegeo_context, :text
    remove_column :budge_requests, :foursquare_category_id, :string
  end
end
