class ButtonHit < ActiveRecord::Base
  attr_accessible :day_of_week, :day_streak, :hour_of_day, :latitude, :longitude, :month_number, :num_clicks_this_hour, :response_minutes, :user_id
end
