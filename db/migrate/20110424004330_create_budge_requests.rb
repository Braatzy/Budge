class CreateBudgeRequests < ActiveRecord::Migration
  def self.up
    create_table :budge_requests do |t|
      t.string :short_id
      t.integer :user_id
      t.integer :alignment, :default => 0
      t.boolean :post_to_budge, :default => false
      t.boolean :post_to_facebook, :default => false
      t.boolean :post_to_twitter, :default => false
      t.boolean :post_to_foursquare, :default => false
      t.string :foursquare_place_id
      t.string :message
      t.integer :total_views, :default => 0
      t.integer :budge_views, :default => 0
      t.integer :facebook_views, :default => 0
      t.integer :twitter_views, :default => 0
      t.integer :foursquare_views, :default => 0
      t.integer :num_signups, :default => 0
      t.integer :num_budges, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :budge_requests
  end
end
