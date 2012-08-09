class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :user_id
      t.string :hashed_id
      t.integer :notification_number, :default => 0
      t.boolean :delivered, :default => false
      t.datetime :delivered_at
      t.integer :delivered_hour_of_day
      t.integer :delivered_day_of_week
      t.integer :delivered_week_of_year
      t.boolean :include_competitive, :default => false
      t.boolean :include_collaborative, :default => false
      t.boolean :include_tip, :default => false
      t.boolean :include_social, :default => false
      t.boolean :include_social_plea, :default => false
      t.boolean :include_gift, :default => false
      t.datetime :responded_at
      t.integer :responded_hour_of_day
      t.integer :responded_day_of_week
      t.integer :responded_week_of_year
      t.integer :method_of_delivery
      t.integer :style_of_message
      t.integer :num_current_traits, :default => 0
      t.integer :num_additional_traits, :default => 0
      t.text :traits_included
      t.integer :randomness_level, :default => 0
      t.integer :streak, :default => 0
      t.integer :responded_minutes
      t.boolean :direct_link
      t.integer :num_clickthrus, :default => 0
      t.boolean :responded, :default => false
      t.boolean :completed_response, :default => false
      t.integer :method_of_response
      t.boolean :shared_results, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
