class NotificationConsolidation < ActiveRecord::Migration
  def self.up
    add_column :notifications, :remote_user_id, :string
    add_column :notifications, :remote_site_token, :string
    add_column :notifications, :remote_post_id, :string
    
    rename_column :notifications, :hashed_id, :short_id
    rename_column :notifications, :style_of_message, :message_style_token
    rename_column :notifications, :traits_included, :message_data
    rename_column :notifications, :method_of_delivery, :delivered_via
    remove_column :notifications, :direct_link    
    remove_column :notifications, :include_competitive    
    remove_column :notifications, :include_collaborative   
    remove_column :notifications, :include_tip  
    remove_column :notifications, :include_social 
    remove_column :notifications, :include_social_plea  
    remove_column :notifications, :include_gift     
    remove_column :notifications, :num_current_traits    
    remove_column :notifications, :num_additional_traits    
    remove_column :notifications, :randomness_level    
    rename_column :notifications, :num_clickthrus, :total_clicks
    change_column :notifications, :total_clicks, :integer, :default => 0
    add_column :notifications, :delivered_immediately, :boolean, :default => false
    add_column :notifications, :num_signups, :integer, :default => 0
    add_column :notifications, :for, :string
    add_column :notifications, :for_id, :integer
    add_column :notifications, :from_system, :boolean, :default => false
    add_column :notifications, :from_user_id, :integer
    add_column :notifications, :delivered_off_hours, :boolean, :default => false
    
    remove_column :budge_requests, :budge_views
    remove_column :budge_requests, :facebook_views
    remove_column :budge_requests, :twitter_views
    remove_column :budge_requests, :num_signups

    remove_column :user_budges, :budge_views
    remove_column :user_budges, :facebook_views
    remove_column :user_budges, :twitter_views
    remove_column :user_budges, :num_signups
    
  end

  def self.down
  end
end
