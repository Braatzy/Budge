class BudgeRequestTimeContext < ActiveRecord::Migration
  def self.up
    add_column :budge_requests, :created_hour_of_day, :integer
    add_column :budge_requests, :created_day_of_week, :integer
    add_column :budge_requests, :created_week_of_year, :integer
    add_column :budge_requests, :facebook_post_id, :string
    add_column :budge_requests, :tweet_id, :string
    add_column :budge_requests, :foursquare_checkin_id, :string
  end

  def self.down
    remove_column :budge_requests, :created_hour_of_day
    remove_column :budge_requests, :created_day_of_week
    remove_column :budge_requests, :created_week_of_year
    remove_column :budge_requests, :facebook_post_id
    remove_column :budge_requests, :tweet_id
    remove_column :budge_requests, :foursquare_checkin_id
  end
end
