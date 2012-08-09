class CreateUserTraits < ActiveRecord::Migration
  def self.up
    create_table :user_traits do |t|
      t.integer :user_id, :null => false
      t.integer :trait_id, :null => false
      t.integer :streak, :default => 0
      t.integer :level, :default => 0
      t.boolean :visible_to_user, :default => true
      t.decimal :desired_notification_frequency, :default => 1
      t.datetime :last_notification_datetime
      t.integer :num_notifications, :default => 0
      t.integer :num_checkins, :default => 0
      t.integer :num_budges_received, :default => 0
      t.integer :num_budges_given, :default => 0
      t.integer :num_budges_completed, :default => 0
      t.integer :num_budges_ignored, :default => 0
      t.decimal :response_rate, :precision => 5, :scale => 2
      t.decimal :avg_response_time, :precision => 8, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :user_traits
  end
end
