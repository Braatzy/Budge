class CreateFoursquareCategories < ActiveRecord::Migration
  def self.up
    create_table :foursquare_categories do |t|
      t.string :category_id
      t.string :name
      t.string :plural_name
      t.string :icon
      t.string :parent_id
      t.string :parent_category_id
      t.integer :num_children, :default => 0
      t.integer :level_deep, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :foursquare_categories
  end
end
