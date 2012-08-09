class PlayerBudge < ActiveRecord::Base
  belongs_to :program_player
  belongs_to :program_budge
  has_many :user_actions
  has_many :player_messages
  has_many :checkins
  serialize :progress_data
  
  # day_of_budge values
  NEEDS_REVIVING = -1
  READY_TO_START = 0
  
  ### CLASS METHODS ###
  
  def self.get_aggregate_status(player_budge_statuses)
    aggregate_status=Hash.new
    STATES.each{|s| aggregate_status[s]=0}
    player_budge_statuses.each do |level,statuses|
      statuses.each{|status,count|  aggregate_status[status]+=count}
    end
    return aggregate_status
  end
  
  
  ### BOOLEAN ATTRIBUTES ###

  def primary_program_budge?
    self.program_player.present? and self.program_player.player_budge_id == self.id
  end
    
  # This is the current player budge and it's scheduled to start in the future
  def scheduled?
    self.status_sym == :scheduled
  end

  # This is the current player budge 
  def in_progress?    
    self.status_sym == :in_progress
  end

  def caught_up?
    self.status_sym == :caught_up
  end

  def time_up?
    self.status_sym == :time_up
  end

  def needs_reviving?
    self.status_sym == :needs_reviving
  end

  def ready_to_start?
    self.status_sym == :ready_to_start
  end

  # Made some progress but didn't "complete" the full task
  # We shouldn't call this completed since completed at the program_player level means that they passed the level
  def completed?
    self.status_sym == :completed
  end

  # Simplifications of the basic statuses
  def playing?
    self.in_progress? or self.caught_up?
  end

  def passed?
    self.completed? and self.stars_final >= 1
  end
  
  def auto_advanced?
    self.completed? and self.stars_final >= 2
  end
  
  def victorious?
    self.completed? and self.stars_final == 3
  end
  
  def lost?
    if self.time_up? and 
      self.program_player.last_checked_in.present? and 
      self.program_player.last_checked_in > Time.now.utc-30.days
      return true
    else
      return false
    end
  end  
  
  
  
  
  
  
  ### NON-BOOLEAN ATTRIBUTES ###

  # Used by all the boolean methods for status
  def status_sym
    if self.stars_final.present?
      return :completed
    else
      if self.primary_program_budge?
        if self.day_of_budge.present? and self.day_of_budge < 1
          if self.day_of_budge == 0
            return :ready_to_start # Ready to be moved to day 1
          else
            return :needs_reviving # Start them on a new budge (determine best place)
          end
        elsif self.day_starts_at.present? and self.day_starts_at > Time.now.utc
          return :scheduled
        else
          old_time_zone = Time.zone
          Time.zone = self.program_player.user.time_zone_or_default
          if self.last_completed_date.present? and self.last_completed_date >= Time.zone.today
            Time.zone = old_time_zone
            return :caught_up
          else
            Time.zone = old_time_zone
            if self.days_late <= 3
              return :in_progress
            else
              return :time_up
            end
          end
        end
      else
        return :unknown
      end
    end
  end

  # Used by /dash.  Should probably be combined with status_sym above
  # get the status of the budge, can be:
  # scheduled: if the start date is in the future
  #    in-progress states happen when the end date is in the future and this is the player's current budge
  # in-progress, no-show: hasn't checked in at all
  # in-progress, perfect: has checked in and completed all actions (as of end of yesterday)
  # in-progress, passing:  has checked in and completed >=2/3 actions (as of end of yesterday)
  # in-progress, failing: has checked in but has completed less than 2/3 of the actions (as of end of yesterday)
  #    past budge states happen when the end date is in the past
  # no-show: didn't check in at all
  # perfect: checked in and did all the actions
  # passed:  checked in and did >=2/3 actions
  # failed:  checked in but did <2/3 actions
  STATES = ['scheduled', 'in-progress', 'in-past', 'no-show', 'perfect', 'passed', 'failed']
  def get_status
    if self.scheduled?
      'scheduled'
    elsif self.in_progress?
      'in-progress'
    else #completed
      if self.checkins.empty?
        'no-show'
      elsif 
        did_do=self.number_actions_victorious
        could_do=self.number_actions_possible
        if did_do==could_do
          'perfect'
        elsif did_do>=((2.0/3.0)*could_do)
          'passed'
        else
          'failed'
        end
      end
    end
  end
  
  def todays_date
    return Time.now.in_time_zone(self.program_player.user.time_zone_or_default).to_date
  end

  def user_actions_for_checkin
    return self.user_actions.where(:day_number => self.day_of_budge).sort_by{|u|u.sort_by}.select{|u|!u.done?}    
  end

  def select_start_date_options
    today = Time.zone.today
    
    dates = []
    if self.scheduled? and self.day_starts_at.present? and (self.day_starts_at.to_date-29.days > today)
      dates << [self.day_starts_at.strftime('%a, %b %d'), self.day_starts_at.to_date.to_s]
    end
    (0..30).each do |number|
      date = today+number.days
      day_name = date.strftime('%a, %b %d')
      if date == today
        day_name = "today"  
      elsif date == today+1.day
        day_name = "tomorrow"
      elsif number % 7 == 0 
        week_num = number/7
        if week_num == 1
          day_name += ": a week away"
        elsif week_num > 1
          day_name += ": #{week_num} weeks away"
        end
      end
      dates << [day_name, date.to_s]
    end
    return dates
  end

  def select_pause_options
    today = Time.zone.today
    
    dates = []
    [1,3,5,7,10,14,21,30,365,1825].each do |number|
      date = today+number.days
      if number == 1
        day_name = '1 day'
      elsif number < 7 or number%10 == 0
        day_name = "#{number} days"
      elsif number == 7
        day_name = '1 week'
      elsif number < 30
        day_name = "#{number/7} weeks"
      elsif number == 30
        day_name = "1 month"
      elsif number < 365
        day_name = "#{number/30} months"
      elsif number == 365
        day_name = "1 year"
      else
        day_name = "#{number/365} years"
      end
      dates << [day_name, date.to_s]
    end
    first_of_month = (today+30.days).end_of_month+1.day
    (0..3).each do |month_num|
      first_of_month = first_of_month+month_num.months
      day_name = first_of_month.strftime('%A, %B %d')
      dates << [day_name, first_of_month.to_s]
    end
    return dates.sort_by{|name,date|Date.parse(date)}
  end

  # Number of days since this day_of_budge started
  def days_late
    if self.day_starts_at
      ((Time.now.utc - self.day_starts_at)/24/60/60).to_i
    else
      if self.deprecated_day_number.present? and self.program_budge.present? and self.deprecated_day_number > self.program_budge.duration_in_days
        return self.deprecated_day_number - self.program_budge.duration_in_days
      else
        return 0
      end
    end
  end
  
  # The number of days remaining, rounding up.
  def days_remaining
    (self.program_budge.duration_in_days+1) - self.day_of_budge
  end
  
  # The number of days remaining, rounding down.
  def days_remaining_round_down
    (self.program_budge.duration_in_days) - self.day_of_budge
  end
  
  def datetime_in_time_zone(date = nil)
    if date.present?
      old_time_zone = Time.zone
      Time.zone = self.program_player.user.time_zone_or_default
      
      new_datetime = Time.zone.parse(date.to_s)
      Time.zone = old_time_zone
      
      return new_datetime
    end
  end

  def day_starts_at_in_time_zone
    if self.day_starts_at.present?
      return self.datetime_in_time_zone(self.day_starts_at)
    else
      return nil
    end
  end
  
  def day_starts_date
    self.day_starts_at_in_time_zone.to_date
  end

  def day_ends_at_in_time_zone
    return self.datetime_in_time_zone(self.day_ends_at)
  end

  def day_ends_at
    self.day_starts_at+3.days
  end

  def start_date_with_restarts
    logger.warn "player_budge.start_date_with_restarts"
    self.day_starts_at 
  end
  
  # Attempt at getting a more realistic finish date, instead of last possible end date given by end_date_with_restarts
  def finish_date
    if self.program_budge.nil?
      return nil
    elsif self.start_date.nil?
      return nil
    end
    duration=self.program_budge.duration_in_days
    default=self.start_date+duration.day
    
    if self.completed?
      #if already finished with level - return date they finished
      return self.last_completed_date.nil? ? default : self.last_completed_date
    else
      return default
    end
  end  
  
  def level_number
    self.program_budge.nil? ? nil : self.program_budge.level
  end
  
  def level_name
    self.program_budge.name
  end
  
  def number_actions_possible
    number = 0
    self.program_budge.program_action_templates.each do |program_action_template|
      if program_action_template.day_number.blank? or program_action_template.day_number == 0
        number += self.program_budge.duration_in_days
      else
        number += 1
      end
    end
    return number
  end

  def number_actions_possible_on_day
    number = 0
    self.program_budge.program_action_templates.each do |program_action_template|
      if program_action_template.day_number.blank? or program_action_template.day_number == 0
        number += 1
      elsif program_action_template.day_number == self.day_of_budge
        number += 1
      end
    end
    return number
  end
  
  def number_actions_victorious
    self.user_actions.select{|a|a.victorious?}.count
  end

  def number_actions_victorious_on_day
    self.user_actions.where(:day_number => self.day_of_budge).select{|a|a.victorious?}.count
  end
    
  ### VERB METHODS ###
  
  # They're pause on this day and need for it to move to day 1 starting on date
  def move_to_day(start_day_of_budge = 1, start_day_date = nil)
    start_day_of_budge = 1 if start_day_of_budge < 1 # If they're at 0 or -1, just start them on day 1
    
    # If we're moving past the last day of the budge  
    if start_day_of_budge > self.program_budge.duration_in_days
      self.end_player_budge(start_day_date, notify = false)
      self.start_recommended_budge(start_day_date, notify = false)    
    
    else
    
      # Set this as the player's current budge
      # Scope time zone for the purposes of this method
      old_time_zone = Time.zone
      Time.zone = self.program_player.user.time_zone_or_default
  
      # Start this player budge tomorrow, in their time zone
      if start_day_date.blank?
        last_date = self.program_player.last_completed_date
        if last_date.blank?
          start_day_date = Time.zone.now+1.day
    
        else 
          # Start them today if they haven't played today yet and it's not past their bedtime
          if last_date < Time.zone.today and Time.zone.now.hour < self.program_player.user.no_notifications_after
            start_day_date = Time.zone.now      
          
          # Otherwise, default to tomorrow,
          else
            start_day_date = Time.zone.now+1.day
          end
        end
      end
      self.update_attributes({:num_crows => 0,
                              :day_of_budge => start_day_of_budge,
                              :day_starts_at => start_day_date.midnight.utc})
  
      self.schedule_time_based_actions_and_messages # Related to a specific day
  
      # Set this as the player's current budge
      self.program_player.update_attributes({:needs_to_play_at => self.day_starts_at})
  
      # Track that they started a new budge
      TrackedAction.add(:new_player_budge_day, self.program_player.user)
  
      # End of time zone scope
      Time.zone = old_time_zone
      
      return true
    end
  end
  
  # You NEED to run this (use delay) after creating a budge (it won't happen automatically)
  def start_player_budge

    if self.program_player.max_level < self.program_budge.level
      raise "Can't access this level yet.  It's #{self.program_budge.level} and is higher than #{self.program_player.max_level}."
    end

    # Set this as the player's current budge
    # Scope time zone for the purposes of this method
    old_time_zone = Time.zone
    Time.zone = self.program_player.user.time_zone_or_default

    # Start this player budge tomorrow, in their time zone
    last_date = self.program_player.last_completed_date
    if last_date.blank?
      today_or_tomorrow = Time.zone.now+1.day

    else 
      # Start them today if they haven't played today yet and it's not past their bedtime
      if last_date < Time.zone.today and Time.zone.now.hour < self.program_player.user.no_notifications_after
        today_or_tomorrow = Time.zone.now      
      
      # Otherwise, default to tomorrow,
      else
        today_or_tomorrow = Time.zone.now+1.day
      end
    end
    self.update_attributes({:start_date => Time.zone.now.to_date,
                            :day_of_budge => 1,
                            :day_starts_at => today_or_tomorrow.midnight.utc,
                            :progress_data => []})

    self.schedule_time_based_actions_and_messages # Related to a specific day
    self.schedule_triggered_actions_and_messages # Related to non-timed triggers (like location)

    # Set this as the player's current budge
    self.program_player.update_attributes({:victorious => nil,
                                           :player_budge_id => self.id,
                                           :level => self.program_budge.level,
                                           :needs_to_play_at => self.day_starts_at})

    # Track that they started a new budge
    TrackedAction.add(:new_player_budge, self.program_player.user)

    # End of time zone scope
    Time.zone = old_time_zone
    
    return true
  end
  
  # 1) Expire any existing actions, delete any unsent messages
  # 2) Create a new set of actions and messages
  def schedule_time_based_actions_and_messages
    self.user_actions.select{|ua|ua.not_done?}.map{|ua|ua.change_status(:expired)}
    self.player_messages.select{|pm|!pm.delivered? and (pm.auto_message.blank? or pm.auto_message.timed?)}.map{|pm|pm.destroy}
    
    # Create new user_actions for this player
    if self.program_budge.program_action_templates.present?
      self.program_budge.action_templates_for_day_number(self.day_of_budge).each do |program_action_template|
        program_action_template.create_actions_for_player_budge(self)      
      end
    end

    # Schedule auto messages
    if self.program_budge.auto_messages.present?
      player_messages_by_day_number = Hash.new(0)
      auto_messages_to_schedule = self.program_budge.auto_messages_for_day_number(self.day_of_budge)
      
      # If they have a hard-coded time, schedule the first message for that time
      if self.program_player.hardcoded_reminder_hour.present?
        first_message = auto_messages_to_schedule.shift
        if first_message.present?
          first_message.schedule_for_player_budge({:time => self.program_player.hardcoded_reminder_hour,
                                                   :program_player => self.program_player,
                                                   :player_budge => self})
        end
      end
      
      # Schedule the remaining messages, if there are any, at the best time
      auto_messages_to_schedule.each do |auto_message|
        auto_message.schedule_for_player_budge({:time => :best,
                                                :program_player => self.program_player,
                                                :player_budge => self})      
      end
    end
  end
  
  # Schedule triggered messages (no action templates currently)
  def schedule_triggered_actions_and_messages
    # Schedule auto messages
    if self.program_budge.auto_messages.present?
      self.program_budge.auto_messages_with_triggers.each do |auto_message|
        auto_message.schedule_for_player_budge({:program_player => self.program_player,
                                                :player_budge => self})      
      end
    end
  end
  
  # Usually done when a player switches to a new budge
  # date is used to calculate_stars
  # notify is used to let user know they're done with the level if this was ended automatically
  def end_player_budge(date = nil, notify = false)

    # End all of these user_actions associated with the budge
    # Cancel all future auto_messages associated with this budge
    self.user_actions.select{|ua|ua.not_done?}.map{|ua|ua.change_status(:ended_early)}
    self.player_messages.select{|pm|!pm.delivered?}.map{|pm|pm.destroy}

    # Make sure the program isn't on this budge anymore
    if self.program_player.player_budge_id == self.id
      self.program_player.update_attributes({:player_budge_id => nil})
    end
      
    # Calculate num stars for this budge
    self.calculate_stars(final = true, date)
    
    if self.passed? and self.program_budge.level >= self.program_player.max_level
      self.program_player.max_level = self.program_budge.level+1
      
      # Mark this program as completed or victorious if they just completed the last level.
      self.mark_program_as_completed_if_it_is
    end
    # Make sure we clear out any future restart dates for this
    self.program_player.update_attributes(:needs_to_play_at => Time.now.utc)
       
    if notify
      via = self.program_player.user.pick_a_contact_method(desperation = 1)
      self.program_player.user.contact_them(via, :completed_level, self) if via
    end
  end
  
  # Currently only moves them forward or repeats current budge. #FIXME add a way to go back a level
  def start_recommended_budge(date = nil, notify = nil)
    if self.passed? 
      # Only auto-move them to the next level if they got 2 or more stars
      if self.auto_advanced?
        next_program_budge = self.program_player.program.next_budge(self.program_budge.level)
        self.program_player.start_budge(next_program_budge, date, notify)
      else 
        self.program_player.start_budge(self.program_budge, date, notify)        
      end
    else
      self.program_player.start_budge(self.program_budge, date, notify)            
    end
  end
    
  # This happens when they click the "DONE" button. Doesn't actually save the checkins (that happens through ajax)
  # Mostly, this saves the entry to the stream and posts it to Facebook's Open Graph
  def save_days_checkin(options = Hash.new)
    raise unless options[:date].present?
    options[:notify] ||= false
    options[:private] ||= false
    options[:share_twitter] ||= false
    options[:share_facebook] ||= false
    
    # Figure out what date we're answering questions for
    @todays_date = self.todays_date
    
    # Make sure we're finalizing a valid date
    if options[:date] <= @todays_date 
      program_player = self.program_player
      
      # Post to Facebook Open Grap
      if facebook_oauth = program_player.user.oauth_for_site_token('facebook') and facebook_oauth.present?
        og_url = "https://#{SECURE_DOMAIN}/store/program/#{program_player.program.token}"
        facebook_oauth.save_graph_action('website', 'play', og_url)
      end  
      
      # Only save an entry if there's at least 1 checkin, or a message, or they're sharing this.
      related_checkins = self.checkins.where(:date => options[:date])
      if related_checkins.present? or options[:message].present? or options[:share_twitter] or options[:share_facebook]
        
        # Come up with a default message for when no message is given (or should that happen on the fly?)
        original_message = options[:message]
        if options[:message].blank?
          options[:message_type] == 'checkin'
          options[:message] = "I checked in to the #{self.program_player.program.name} program!"
        elsif options[:message_type] == 'secret'
          if options[:message].length > 58
            options[:message] = "My secret ingredient is #{options[:message]}"             
          else
            options[:message] = "My secret ingredient for the #{self.program_player.program.name} program is #{options[:message]}"     
          end 
        elsif options[:message_type] == 'nemesis'
          if options[:message].length > 68
            options[:message] = "My nemesis is #{options[:message]}"                    
          else
            options[:message] = "My nemesis in the #{self.program_player.program.name} program is #{options[:message]}"                    
          end
        end
        
        @entry_attributes = {:user_id => self.program_player.user_id,
                             :program_id => self.program_player.program_id,
                             :program_player_id => self.program_player_id,
                             :program_budge_id => self.program_budge_id,
                             :player_budge_id => self.id,
                             :parent_id => nil,
                             :location_context_id => (options[:location_context].present? ? options[:location_context].id : nil),
                             :privacy_setting => (options[:private] ? 0 : 10),
                             :message => options[:message],
                             :message_type => options[:message_type],
                             :original_message => original_message,
                             :date => Time.zone.today.to_date,
                             :post_to_coach => true,
                             :post_to_twitter => options[:share_twitter],
                             :post_to_facebook => options[:share_facebook]}

        @existing_entry = Entry.where(:user_id => self.program_player.user_id,
                                      :player_budge_id => self.id,
                                      :date => Time.zone.today.to_date).first
        if @existing_entry
          @existing_entry.update_attributes(@entry_attributes)
          @existing_entry.save_metadata
          @existing_entry.post_remotely
        else
          @entry = Entry.create(@entry_attributes)
        end
      end
        
    end
    return true
  end

  def shift_start_date(new_start_date_string)
    return false unless self.primary_program_budge?
    day_start_date = Date.parse(new_start_date_string.to_s)
    self.move_to_day(self.day_of_budge, day_start_date)
  end

  def self.get_aggregate_status(player_budge_statuses)
    aggregate_status=Hash.new
    STATES.each{|s| aggregate_status[s]=0}
    player_budge_statuses.each do |level,statuses|
      statuses.each{|status,count|  aggregate_status[status]+=count}
    end
    return aggregate_status
  end
  
  # Send them 3 reminders at the end of each day that they don't do their day's work / deny budge
  def crow
    self.schedule_time_based_actions_and_messages # Reschedule messages and actions
    self.update_attributes(:num_crows => self.num_crows+1)
  end

  # They need to come back and restart this program
  def put_to_sleep
    if self.program_player.present?
      self.update_attributes(:num_crows => self.num_crows+1, :day_of_budge => NEEDS_REVIVING)
      self.program_player.user.contact_them(:email, :moment_of_truth, self)    
    end
  end
  
  ### AFTER FILTERS ###
  
  def checkin_metadata_summary(for_date = nil)
    for_date ||= self.last_completed_date
    summary_data = {:checkins => {}, :unique_checkin_dates => 0}
    
    unique_dates = self.program_player.unique_checkin_dates(for_date, 30)
    summary_data[:unique_checkin_string] = unique_dates[:string]
    summary_data[:unique_checkin_dates] = unique_dates[:num_unique_dates]
    
    # Get all of the checkins for the most recently checked in date
    checkins_for_date = self.checkins.where(:date => for_date)

    verbs = Hash.new
    checkins_for_date.each do |checkin|
      # Only once per verb
      next if verbs[checkin.trait.verb].present?
      verbs[checkin.trait.verb] = true
      summary_data[:checkins][checkin.id] = checkin.get_metadata_summary
    end
    return summary_data
  end

  # Checks to see if this player_budge has all of its actions completed, if so, it ends the budge
  def check_and_complete_if_done(date, notify = false)
    @user_actions = self.user_actions || []
    
    # For whole budge
    @num_actions = self.number_actions_possible
    @num_actions_victorious = self.number_actions_victorious

    # They're done with this budge
    if @num_actions == @num_actions_victorious or self.time_up? or self.completed?

      # Update last completed date
      self.update_attributes(:last_completed_date => date)
    
      self.end_player_budge(date, notify)
      self.start_recommended_budge(date, notify)    
      
      # Update the number of invitations they have. Notify them if they got any new ones.
      self.program_player.calculate_num_invites
    
    # If they aren't yet finished with their actions for this budge
    else
    
      # For this day
      @num_actions_on_day = self.number_actions_possible_on_day
      @num_actions_victorious_on_day = self.number_actions_victorious_on_day

      if @num_actions_on_day == @num_actions_victorious_on_day

        # Update last completed date
        self.update_attributes(:last_completed_date => date)
        
        # Move them to the next day
        if self.day_of_budge < self.program_budge.duration_in_days
          self.move_to_day(self.day_of_budge+1, date+1)
        
        # Move them to the next budge
        elsif self.day_of_budge >= self.program_budge.duration_in_days
          self.end_player_budge(date, notify)
          self.start_recommended_budge(date, notify)    
        end

      # They still have some actions to complete
      else
        self.program_player.update_needs_to_play_at(self)
      end
    end    
  end
  
  # They have completed this program... and may or may not be victorious
  def mark_program_as_completed_if_it_is
    if self.passed? and !self.program_player.completed? and self.program_budge.level >= self.program_player.program.last_level
      self.program_player.update_attributes(:completed => true, :victorious => (self.program_player.victorious == false ? nil : self.program_player.victorious))
      # self.program_player.user.contact_them(:email, :completed_program_congrats, self.program_player)
      Mailer.message_for_habit_labbers("#{self.program_player.user.name} completed #{self.program_player.program.name}!",
                                       "One of you Labbers should take a look at their progress through the program and "+
                                       "congratulate them on Twitter! \n\nhttp://#{DOMAIN}/dash/user/#{self.program_player.user.id}").deliver rescue nil
    end
  end

  # Update stars_subtotal and stars_final if necessary
  def calculate_stars(final = false, date = nil)
    if final
      did_do = self.number_actions_victorious
      could_do = self.number_actions_possible
      if could_do > 0
        self.stars_subtotal = (did_do*3.0/could_do)
        self.stars_final = self.stars_subtotal.floor
        self.program_player.update_score_data(self)
        self.save
      end
    end
  end

  
  ### DEPRECATED ###
  # Use 1 time before deleting restart_at columns
  #    return :needs_to_choose_another_budge
  #    return :needs_contact_info    
  #    return :time_up
  #    return :scheduled
  #    return :caught_up
  #    return :playing
  def self.migrate_to_day_starts_at  
    PlayerBudge.all.each do |player_budge|
      program_player = player_budge.program_player
      next unless program_player.present?
      next unless player_budge.program_budge.present?

      # Player Budges that are scheduled for the future... and were not auto_scheduled.
      if program_player.respond_to?(:restart_at) and program_player.restart_at.present? and 
         player_budge.datetime_in_time_zone(program_player.restart_at).midnight > Time.now.utc and 
         !player_budge.lazy_scheduled? then
        player_budge.update_attributes({:num_crows => 0,
                                        :day_starts_at => player_budge.datetime_in_time_zone(program_player.restart_at).midnight,
                                        :day_of_budge => program_player.restart_day_number})
        player_budge.move_to_day(player_budge.day_of_budge, player_budge.day_starts_at)


      # Playing and either checked in or was not lazy scheduled
      elsif player_budge.caught_up? or player_budge.playing?
        
        if player_budge.deprecated_day_number.present? and player_budge.deprecated_day_number <= player_budge.program_budge.duration_in_days
          if player_budge.checkins.present? or !player_budge.lazy_scheduled?
            next_day = player_budge.datetime_in_time_zone(Time.now.utc).midnight  
            player_budge.update_attributes({:num_crows => 0,
                                            :day_starts_at => next_day.utc,
                                            :day_of_budge => player_budge.deprecated_day_number})
            player_budge.move_to_day(player_budge.day_of_budge, player_budge.day_starts_at)
          else
            if player_budge.last_completed_date.present?
              last_day = player_budge.datetime_in_time_zone(player_budge.last_completed_date).midnight+1.day
            elsif player_budge.start_date
              last_day = player_budge.datetime_in_time_zone(player_budge.start_date).midnight+1.day              
            else
              last_day = player_budge.datetime_in_time_zone(player_budge.created_at).midnight+1.day              
            end
            player_budge.update_attributes({:day_starts_at => last_day.utc,
                                            :day_of_budge => NEEDS_REVIVING})          
            player_budge.move_to_day(player_budge.day_of_budge, player_budge.day_starts_at)
          end
        
        else
          logger.warn "not doing anything for player budge: #{player_budge.id}"
        end
      end
    end
  end

  # Either the # days since started, or the # days since the last pause (minus the num_days it was paused at)
  def deprecated_day_number
    time_zone = self.program_player.user.time_zone_or_default
    now_in_time_zone = Time.now.in_time_zone(time_zone)
    
    # If this budge has been paused, return the number of days until it is UNpaused
    # Note that if they paused this on day 6, and it's starting tomorrow, the day number will still be -1, but
    # tomorrow it will be 6, since it will resume with the day number that it was paused at.
    if !self.program_player.respond_to?(:restart_at)
      if self.program_player.temp_restart_at.present? and self.program_player.temp_restart_day_number.present?
        restart_at_in_time_zone = self.datetime_in_time_zone(self.program_player.temp_restart_at)
        return (now_in_time_zone.to_date-self.program_player.temp_restart_at.to_date+1).ceil
        
      elsif self.start_date.present?
        start_date_in_time_zone = datetime_in_time_zone(self.start_date).midnight
      
        # Rounding up, since start dates are set to 1 day in the future by default
        return ((now_in_time_zone - start_date_in_time_zone)/60/60/24).ceil
      else
        return nil
      end
    elsif self.program_player.restart_at.present? and self.program_player.restart_day_number.present?
      restart_at_in_time_zone = self.datetime_in_time_zone(self.program_player.restart_at)
      return (now_in_time_zone.to_date-self.program_player.restart_at.to_date+1).ceil
      
    elsif self.start_date.present?
      start_date_in_time_zone = datetime_in_time_zone(self.start_date).midnight
    
      # Rounding up, since start dates are set to 1 day in the future by default
      return ((now_in_time_zone - start_date_in_time_zone)/60/60/24).ceil
    else
      return nil
    end
  end
    
  def deprecated_start_date_with_restarts
    return self.start_date unless self.program_player.present?
    time_zone = self.program_player.user.time_zone_or_default
    now_in_time_zone = Time.now.in_time_zone(time_zone)
    
    # If this budge has been paused
    if self.program_player.restart_at.present? and self.program_player.restart_day_number.present?
      restart_at_in_time_zone = self.datetime_in_time_zone(self.program_player.restart_at)
      return restart_at_in_time_zone.to_date
    
    # If it hasn't been paused, just go by the budge start date
    else
      return self.start_date
    end
  end

end


# == Schema Information
#
# Table name: player_budges
#
#  id                  :integer(4)      not null, primary key
#  program_player_id   :integer(4)
#  program_budge_id    :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#  start_date          :date
#  last_completed_date :date
#  stars_final         :integer(4)
#  stars_subtotal      :decimal(11, 10) default(0.0)
#  ended_early         :boolean(1)      default(FALSE)
#  lazy_scheduled      :boolean(1)      default(FALSE)
#  day_of_budge        :integer(4)      default(1)
#  day_starts_at       :datetime
#  progress_data       :text
#  num_crows           :integer(4)      default(0)
#

