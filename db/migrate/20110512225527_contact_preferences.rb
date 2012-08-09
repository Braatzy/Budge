class ContactPreferences < ActiveRecord::Migration
  def self.up
    add_column :users, :contact_by_email_pref, :integer, :default => 10
    add_column :users, :contact_by_sms_pref, :integer, :default => 10
    add_column :users, :contact_by_public_tweet_pref, :integer, :default => 5
    add_column :users, :contact_by_dm_tweet_pref, :integer, :default => 5
    add_column :users, :contact_by_robocall_pref, :integer, :default => 0
    
    add_column :users, :contact_by_email_score, :decimal, :precision => 10, :scale => 8, :default => 10
    add_column :users, :contact_by_sms_score, :decimal, :precision => 10, :scale => 8, :default => 10
    add_column :users, :contact_by_public_tweet_score, :decimal, :precision => 10, :scale => 8, :default => 10
    add_column :users, :contact_by_dm_tweet_score, :decimal, :precision => 10, :scale => 8, :default => 10
    add_column :users, :contact_by_robocall_score, :decimal, :precision => 10, :scale => 8, :default => 10
  end

  def self.down
    remove_column :users, :contact_by_email_pref
    remove_column :users, :contact_by_sms_pref
    remove_column :users, :contact_by_public_tweet_pref
    remove_column :users, :contact_by_dm_tweet_pref
    remove_column :users, :contact_by_robocall_pref

    remove_column :users, :contact_by_email_score
    remove_column :users, :contact_by_sms_score
    remove_column :users, :contact_by_public_tweet_score
    remove_column :users, :contact_by_dm_tweet_score
    remove_column :users, :contact_by_robocall_score
  end
end
