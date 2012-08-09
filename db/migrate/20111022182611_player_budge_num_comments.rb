class PlayerBudgeNumComments < ActiveRecord::Migration
  def self.up
    add_column :player_budges, :num_daily_reviews, :integer, :default => 0
    add_column :player_budges, :num_times_shared_with_coach, :integer, :default => 0
    add_column :player_budges, :num_times_shared_with_friends, :integer, :default => 0
    
    add_column :checkins, :player_budge_id, :integer
    change_column :checkins, :latitude, :decimal, :precision => 15, :scale => 10
    change_column :checkins, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :player_budges, :num_daily_reviews
    remove_column :player_budges, :num_times_shared_with_coach
    remove_column :player_budges, :num_times_shared_with_friends
    remove_column :checkins, :player_budge_id

    change_column :checkins, :latitude, :integer
    change_column :checkins, :longitude, :integer
  end
end
