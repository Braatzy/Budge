class PracticeChangingController < ApplicationController
  layout 'practice_changing'
  before_filter :authenticate_user!, :only => [:button, :hit_button]
  
  def index
  
  end
  
  def button
    @request_location = true
    @suppress_sidebar = true
    
    @previous_hit = ButtonHit.where(:user_id => current_user.id).order('created_at DESC').first
    @stats_hash = Hash.new
    
    # Figure out streak
    @time_zone_now = Time.zone.now
    if @previous_hit.present?
      if @previous_hit.date == @time_zone_now.to_date or @previous_hit.date == (@time_zone_now.to_date-1.day)
        @stats_hash[:day_streak] = @previous_hit.day_streak     
      else
        @stats_hash[:day_streak] = 0
        @stats_hash[:days_ago] = @time_zone_now.to_date - @previous_hit.date
      end
    else
      @stats_hash[:day_streak] = 0     
    end
  end
  
  def hit_button
    @time_zone_now = Time.zone.now
    @button_hit = ButtonHit.find_or_initialize_by_user_id_and_date_and_hour_of_day(current_user.id, @time_zone_now.to_date, @time_zone_now.hour)
    @button_hit.attributes = {:latitude => (@button_hit.latitude.present? ? @button_hit.latitude : params[:latitude]),
                              :longitude => (@button_hit.longitude.present? ? @button_hit.longitude : params[:longitude]),
                              :num_clicks_this_hour => @button_hit.num_clicks_this_hour + 1,
                              :day_of_week => @time_zone_now.wday, # 0 = Sunday
                              :month_number => @time_zone_now.month}
    @previous_hit = ButtonHit.where(:user_id => current_user.id).where('created_at < ?', @time_zone_now.utc).order('created_at DESC').first

    # Figure out the streak
    if @previous_hit.present?
      if @previous_hit.date == @button_hit.date
        @button_hit.day_streak = @previous_hit.day_streak
      elsif @previous_hit.date == @button_hit.date - 1.day
        @button_hit.day_streak = @previous_hit.day_streak+1
      else
        @button_hit.day_streak = 1
      end
    else
      @button_hit.day_streak = 1
    end
    @button_hit.save
    @total_hits = ButtonHit.where(:user_id => current_user.id).sum(:num_clicks_this_hour)
    @total_hits_today = ButtonHit.where(:user_id => current_user.id, :date => @time_zone_now.to_date).sum(:num_clicks_this_hour)
    @hits_at_this_hour = ButtonHit.where(:user_id => current_user.id, :date => @time_zone_now.to_date, :hour_of_day => @button_hit.hour_of_day)


    @stats_hash = {:button_hit => @button_hit,
                   :day_streak => @button_hit.day_streak,
                   :clicks => @total_hits,
                   :clicks_today => @total_hits_today,
                   :clicks_at_this_hour => @hits_at_this_hour.sum(:num_clicks_this_hour)}

    respond_to do |format|
      format.js
    end  
  end
  
end
