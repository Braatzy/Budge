# == Schema Information
#
# Table name: visit_stats
#
#  id                 :integer(4)      not null, primary key
#  constrained_by     :string(255)
#  constrained_by_id1 :string(255)
#  constrained_by_id2 :string(255)
#  constrained_by_id3 :string(255)
#  num_visits         :integer(4)      default(0)
#  percent_visits     :decimal(5, 2)   default(0.0)
#  created_at         :datetime
#  updated_at         :datetime
#

class VisitStat < ActiveRecord::Base

  # Update all users who haven't been updated in last 7 days
  def self.lazy_update
    self.update_all_users(lazy = true)
    self.update_global_stats
    return true
  end

  def self.update_global_stats
    # global_hour (all user stats for each hour of the day)
    total_visits = VisitStat.sum(:num_visits, :conditions => ['constrained_by = ?', 'user_hour'])
    (0..24).each do |hour|
      visits_this_hour = VisitStat.sum(:num_visits, :conditions => ['constrained_by = ? AND constrained_by_id2 = ?', 
                                                                    'user_hour', hour.to_s])
      next unless visits_this_hour > 0
      vs = VisitStat.find_or_initialize_by_constrained_by_and_constrained_by_id1('global_hour', hour.to_s)
      vs.update_attributes({:num_visits => visits_this_hour,
                            :percent_visits => (visits_this_hour*100/total_visits.to_f)})
      
    end
    
    # global_day_and_hour (all user stats for each hour of each day)
    total_visits = VisitStat.sum(:num_visits, :conditions => ['constrained_by = ?', 'user_day_and_hour'])
    (0..6).each do |day|
      (0..24).each do |hour|
        visits_this_day_and_hour = VisitStat.sum(:num_visits, :conditions => ['constrained_by = ? AND constrained_by_id2 = ? AND constrained_by_id3 = ?', 
                                                                              'user_day_and_hour', day.to_s, hour.to_s])
        next unless visits_this_day_and_hour > 0
        vs = VisitStat.find_or_initialize_by_constrained_by_and_constrained_by_id1_and_constrained_by_id2('global_day_and_hour', day.to_s, hour.to_s)
        vs.update_attributes({:num_visits => visits_this_day_and_hour,
                              :percent_visits => (visits_this_day_and_hour*100/total_visits.to_f)})
        
      end
    end  
    return true  
  end

  # Update all user (defaults to being lazy)
  def self.update_all_users(lazy = true)
    User.select(:id).each_slice(1000) do |user_ids|
      user_ids.each do |user_id|
        user = User.find user_id
        self.update_user(user, lazy)
      end
    end
    return true
  end

  # Update a particular user  
  def self.update_user(user, lazy = true)
  
    # No need to update if they're heavy users or very light users
    if lazy and user.visit_stats_updated.present? 
    
      # We have enough data on them for now... lets just use what we have
      if user.visit_stats_updated > Time.now-7.days and user.visit_stats_sample_size > 100
        p "Skipped heavy #{user.name}"
        return 
      
      # They haven't been back in a while, so no need to update
      elsif user.last_logged_in and user.last_logged_in < Time.now-7.days
        p "Skipped lite #{user.name}"
        return 
      
      end
    end
    p "Processing #{user.id}: #{user.name}"
    
    total_visits = 0
    hour_hash = Hash.new(0)
    hour_and_day_hash = Hash.new

    user.checkins.find(:all, :order => 'created_at DESC', :limit => 1000).each do |checkin|
      hour_hash[checkin.hour_of_day] += 1
      hour_and_day_hash[checkin.day_of_week] ||= Hash.new(0)
      hour_and_day_hash[checkin.day_of_week][checkin.hour_of_day] += 1            
      total_visits += 1
    end
    
    hour_hash.each do |hour, num_visits|
      next unless num_visits > 0
      vs = VisitStat.find_or_initialize_by_constrained_by_and_constrained_by_id1_and_constrained_by_id2('user_hour', user.id.to_s, hour.to_s)
      vs.update_attributes({:num_visits => num_visits,
                            :percent_visits => (num_visits.to_f*100/total_visits.to_f)})
    end

    hour_and_day_hash.each do |day, hour_hash_for_day|
      next unless hour_hash_for_day.present?
      
      hour_hash_for_day.each do |hour, num_visits|
        next unless num_visits > 0
        vs = VisitStat.find_or_initialize_by_constrained_by_and_constrained_by_id1_and_constrained_by_id2_and_constrained_by_id3('user_day_and_hour', user.id.to_s, day.to_s, hour.to_s)
        vs.update_attributes({:num_visits => num_visits,
                              :percent_visits => (num_visits.to_f*100/total_visits.to_f)})
      
      end
    end
    
    user.update_attributes({:visit_stats_updated => Time.now.utc,
                            :visit_stats_sample_size => total_visits})
  end

end
