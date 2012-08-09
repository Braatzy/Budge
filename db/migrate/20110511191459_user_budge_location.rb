class UserBudgeLocation < ActiveRecord::Migration
  def self.up
    change_column :user_budges, :user_id, :integer, :null => true
    add_column :user_budges, :short_id, :string
    
    add_column :user_budges, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :user_budges, :longitude, :decimal, :precision => 15, :scale => 10
    
    add_column :user_budges, :alignment, :integer
    add_column :user_budges, :do, :boolean

    add_column :user_budges, :remote_user_id, :string
    add_column :user_budges, :remote_post_id, :string
    add_column :user_budges, :post_to_facebook, :boolean, :default => false
    add_column :user_budges, :post_to_twitter, :boolean, :default => false
    
    add_column :user_budges, :created_hour_of_day, :integer
    add_column :user_budges, :created_day_of_week, :integer
    add_column :user_budges, :created_week_of_year, :integer

    add_column :user_budges, :responded_hour_of_day, :integer
    add_column :user_budges, :responded_day_of_week, :integer
    add_column :user_budges, :responded_week_of_year, :integer
    add_column :user_budges, :responded_minutes, :integer
    
    add_column :user_budges, :num_nonsupporters, :integer, :default => 0
    add_column :user_budges, :budge_group_id, :integer
    add_column :user_budges, :budge_set_id, :integer
    
    add_column :user_budges, :total_views, :integer, :default => 0
    add_column :user_budges, :budge_views, :integer, :default => 0
    add_column :user_budges, :facebook_views, :integer, :default => 0
    add_column :user_budges, :twitter_views, :integer, :default => 0
    add_column :user_budges, :num_signups, :integer, :default => 0
  end

  def self.down
    change_column :user_budges, :user_id, :integer, :null => false
    remove_column :user_budges, :short_id

    remove_column :user_budges, :latitude
    remove_column :user_budges, :longitude
    
    remove_column :user_budges, :alignment
    remove_column :user_budges, :do

    remove_column :user_budges, :remote_user_id
    remove_column :user_budges, :remote_post_id
    remove_column :user_budges, :post_to_facebook
    remove_column :user_budges, :post_to_twitter
    
    remove_column :user_budges, :created_hour_of_day
    remove_column :user_budges, :created_day_of_week
    remove_column :user_budges, :created_week_of_year

    remove_column :user_budges, :responded_hour_of_day
    remove_column :user_budges, :responded_day_of_week
    remove_column :user_budges, :responded_week_of_year
    remove_column :user_budges, :responded_minutes
    
    remove_column :user_budges, :num_nonsupporters
    remove_column :user_budges, :budge_group_id
    remove_column :user_budges, :budge_set_id

    remove_column :user_budges, :total_views
    remove_column :user_budges, :budge_views
    remove_column :user_budges, :facebook_views
    remove_column :user_budges, :twitter_views
    remove_column :user_budges, :num_signups

  end
end
