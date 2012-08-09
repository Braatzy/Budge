class FoursquareCategoryToTrait < ActiveRecord::Migration
  def self.up
    add_column :foursquare_categories, :trait_token, :string
  end

  def self.down
    remove_column :foursquare_categories, :trait_token
  end
end
