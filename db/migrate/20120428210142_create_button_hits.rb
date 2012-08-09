class CreateButtonHits < ActiveRecord::Migration
  def change
    create_table :button_hits do |t|
      t.integer :user_id
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.integer :num_clicks_this_hour, :default => 0
      t.date    :date
      t.integer :hour_of_day
      t.integer :day_of_week
      t.integer :month_number
      t.integer :day_streak
      t.integer :response_minutes

      t.timestamps
    end
  end
end
