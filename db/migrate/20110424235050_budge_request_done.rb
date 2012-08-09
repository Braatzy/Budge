class BudgeRequestDone < ActiveRecord::Migration
  def self.up
    add_column :budge_requests, :delivered, :boolean, :default => false
    add_column :budge_requests, :foursquare_category_name, :string
  end

  def self.down
    remove_column :budge_requests, :delivered
    remove_column :budge_requests, :foursquare_category_name
  end
end
