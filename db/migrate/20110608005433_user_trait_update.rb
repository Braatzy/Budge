class UserTraitUpdate < ActiveRecord::Migration
  def self.up
    rename_column :users, :num_given_budges, :num_sent_budges
    rename_column :users, :num_given_budges_completed, :num_sent_budges_completed
    add_column :users, :num_sent_budges_successful, :integer, :default => 0
    add_column :users, :num_successful_budges, :integer, :default => 0

    remove_column :user_traits, :streak
    remove_column :user_traits, :visible_to_user
    remove_column :user_traits, :desired_notification_frequency
    remove_column :user_traits, :last_notification_datetime
    remove_column :user_traits, :num_notifications
    remove_column :user_traits, :response_rate
    remove_column :user_traits, :avg_response_time
    remove_column :user_traits, :num_budges_ignored
    change_column :user_traits, :active, :boolean, :default => true
    
    # num_budges_received
    # num_budges_completed
    add_column :user_traits, :num_budges_successful, :integer, :default => 0
    add_column :user_traits, :sum_budges_alignment, :integer, :default => 0
    
    rename_column :user_traits, :num_budges_given, :num_sent_budges
    add_column :user_traits, :num_sent_budges_completed, :integer, :default => 0
    add_column :user_traits, :num_sent_budges_successful, :integer, :default => 0
    add_column :user_traits, :sum_sent_budges_alignment, :integer, :default => 0
  end

  def self.down
    rename_column :users, :num_sent_budges, :num_given_budges
    rename_column :users, :num_sent_budges_completed, :num_given_budges_completed
    remove_column :users, :num_sent_budges_successful
    remove_column :users, :num_successful_budges

    add_column :user_traits, :streak, :integer, :default => 0
    add_column :user_traits, :visible_to_user, :boolean, :default => false
    add_column :user_traits, :desired_notification_frequency, :integer, :default => 1
    add_column :user_traits, :last_notification_datetime, :datetime
    add_column :user_traits, :num_notifications, :integer, :default => 0
    add_column :user_traits, :response_rate, :decimal, :precision => 5, :scale => 2
    add_column :user_traits, :avg_response_time, :integer
    add_column :user_traits, :num_budges_ignored, :integer, :default => 0
    change_column :user_traits, :active, :boolean, :default => false
    
    # num_budges_received
    # num_budges_completed
    remove_column :user_traits, :num_budges_successful
    remove_column :user_traits, :sum_budges_alignment
    
    rename_column :user_traits, :num_sent_budges, :num_budges_given
    remove_column :user_traits, :num_sent_budges_completed
    remove_column :user_traits, :num_sent_budges_successful
    remove_column :user_traits, :sum_sent_budges_alignment
  end
end
