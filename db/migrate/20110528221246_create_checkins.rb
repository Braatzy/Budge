class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins do |t|
      t.integer :user_id
      t.boolean :is_budgee, :default => true
      t.integer :user_budge_id
      t.integer :trait_id
      t.integer :latitude
      t.integer :longitude
      t.boolean :did_action, :default => false
      t.boolean :was_desired, :default => true
      t.boolean :completed_budge, :default => false
      t.text :comment
      t.integer :disputable_by_id
      t.boolean :disputed, :default => false
      t.text :disputed_reason
      t.integer :amount_integer, :default => 0
      t.decimal :amount_decimal, :precision => 10, :scale => 2
      t.string :amount_string
      t.text :amount_text
      t.datetime :checkin_datetime
      t.boolean :checkin_datetime_approximate, :default => false
      t.integer :hour_of_day
      t.integer :day_of_week
      t.integer :week_of_year
      t.string :checkin_via
      t.boolean :needs_confirmation, :default => false
      t.boolean :confirmed, :default => false
      t.boolean :post_to_facebook, :default => false
      t.boolean :post_to_twitter, :default => false
      t.boolean :post_to_foursquare, :default => false
      t.string :facebook_post_id
      t.string :tweet_id
      t.string :foursquare_checkin_id
      t.string :foursquare_venue_id
      t.string :foursquare_category_id
      t.integer :end_clock_remaining

      t.timestamps
    end
  end

  def self.down
    drop_table :checkins
  end
end
