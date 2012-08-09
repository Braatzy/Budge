class ProgramPlayer < ActiveRecord::Base
  belongs_to :program
  belongs_to :user
  belongs_to :player, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :player_budge # Current budge in progress
  belongs_to :program_coach # Current coach
  belongs_to :coach, :foreign_key => 'coach_user_id', :class_name => 'User' # Redundant
  has_many :player_budges, :order => :created_at, :dependent => :destroy
  has_many :player_notes, :dependent => :destroy
  has_many :player_messages, :dependent => :destroy
  has_many :supporters, :dependent => :destroy
  has_many :active_supporters, :class_name => 'Supporter', :conditions => ['active = ?', true]
  has_many :checkins
  has_many :leaders
  
  after_create :thanks_for_purchasing
  
  serialize :coach_data
  serialize :score_data
  
  COACH_FLAG_FINE = 0
  COACH_FLAG_DANGER = 1
  COACH_FLAG_LOST = 2
  COACH_FLAG_DROPPED = 3
  COACH_FLAG_RECOVERED = 4
  COACH_FLAG = {COACH_FLAG_FINE => 'just fine',
                COACH_FLAG_DANGER => 'in danger',
                COACH_FLAG_LOST => 'lost',
                COACH_FLAG_DROPPED => 'dropped',
                COACH_FLAG_RECOVERED => 'recovered'}
  
  ### TEMPORARY migration helpers ### 

  def temp_restart_at
    logger.warn "calling deprecated program_player.restart_at"
    return nil unless self.player_budge.present?
    if self.respond_to?(:restart_at)
      return self.restart_at    
    else
      return self.player_budge.day_starts_at
    end
  end

  def temp_restart_day_number
    logger.warn "calling deprecated program_player.restart_day_number"
    return nil unless self.player_budge.present?
    if self.respond_to?(:restart_day_number)
      return self.restart_day_number    
    else
      return self.player_budge.day_of_budge
    end
  end
  
  ### CLASS METHODS ###
  
  # We send a reminder 3 days in a row when you are playing a budge...
  def self.crow_three_times
    PlayerBudge.where(['stars_final is null AND day_of_budge > 0 AND day_starts_at < ?', 
                       Time.now.utc]).each do |player_budge|
      
      next unless player_budge.primary_program_budge?
      
      # If they didn't do everything that they should have for this day
      days_late = player_budge.days_late
      if days_late > 0 and player_budge.number_actions_possible_on_day > player_budge.number_actions_victorious_on_day        
        old_time_zone = Time.zone
        Time.zone = player_budge.program_player.user.time_zone_or_default
        
        if days_late >= 1 and player_budge.num_crows < 1
          player_budge.crow
        elsif days_late >= 2 and player_budge.num_crows < 2
          player_budge.crow
        elsif days_late >= 3 and player_budge.num_crows < 3
          player_budge.crow
        elsif days_late >= 4 and player_budge.num_crows < 4
          player_budge.crow
        elsif days_late >= 5 and player_budge.num_crows >= 4
          player_budge.put_to_sleep
        end

        Time.zone = old_time_zone                
      end
    end
  end

  def self.deliver_unsent_player_messages
    @unsent_messages = PlayerMessage.find(:all, :conditions => ['delivered = ? AND deliver_at < ? AND send_attempts < ?', false, (Time.now.utc+30.minutes), 3])
    @unsent_messages.each do |player_message|
      player_message.deliver_message
    end
  end

  # Only used once, and by dash controller
  def self.update_last_checked_in_for_all_players
    ProgramPlayer.all.each do |pp|
       pp.update_attributes(:last_checked_in => pp.get_latest_checkin_date)
     end
   end

  def self.flags_for_coach
    [['all is well', COACH_FLAG_FINE], ['in danger', COACH_FLAG_DANGER], ['end coaching', COACH_FLAG_LOST]]
  end
  
  def self.player_buckets_for_coach(user)
    @program_players = ProgramPlayer.where(['program_id is not null AND coach_user_id = ? AND active = ?', user.id, true]).
                                     order('users.last_logged_in').
                                     includes([:user])

    @player_buckets = {'total' => @program_players.size, 
                       'Future' => Array.new, '0-3' => Array.new, '4-7' => Array.new, '8-14' => Array.new, '15+' => Array.new, 
                       'New' => Array.new, 'Danger' => Array.new, 'Lost' => Array.new, 'Dropped' => Array.new, 'Recovered' => Array.new}
    
    @program_players.each do |program_player|
      @player_buckets[program_player.player_to_coach_bucket] ||= Array.new
      @player_buckets[program_player.player_to_coach_bucket] << program_player
    end
    return @player_buckets
  end
  
    
  ### BOOLEAN ATTRIBUTES ###
  
  def playing?
    self.player_budge.present? and self.player_budge.in_progress?
  end
  
  def scheduled?
    self.player_budge.present? and self.player_budge.scheduled? 
  end

  # has the player checked in in the last 3 days
  def engaged?
    self.has_checked_in_last(3.days)
  end

  def is_long_lost?
    !self.has_checked_in_last(30.days)
  end
  
  def ended?
    self.victorious != nil
  end
  
  def defeated?
    self.victorious == false
  end
  
  # scheduled to start within the next amount of time from now
  def scheduled_within(time_from_now = 3.days)
    if !self.scheduled?
      return false
    else 
      return (self.player_budge.day_starts_at <= self.player_budge.day_starts_at + time_from_now)
    end
  end

  # has the player started the program yet
  def has_started_program?
    self.player_budges.count>0 
  end
  
  # is the player in limbo
  # in limbo is defined as has started and has finished and next budge not scheduled
  def in_limbo?
    if not self.has_started_program?
      false
    elsif not self.player_budge.present?
      false
    elsif not self.player_budge.start_date.present?
      true
    else
      false
    end
  end
  
  def needs_to_choose_another_budge?
    self.player_budge.blank? or self.player_budge.stars_final.present? or self.player_budge.day_of_budge == PlayerBudge::NEEDS_REVIVING
  end
  
  def caught_up?
    self.player_budge.present? and self.player_budge.caught_up?
  end

  def flagged_as_inactive?
    if self.coach_flag.blank? or self.coach_flag == ProgramPlayer::COACH_FLAG_FINE or self.coach_flag == ProgramPlayer::COACH_FLAG_DANGER or self.coach_flag == ProgramPlayer::COACH_FLAG_RECOVERED
      return false
    else
      return true
    end
  end  

  # has a player checked in in the last time_amount
  def has_checked_in_last(time_amount=3.days)
    self.checkins.since(Time.now.utc - time_amount).size > 0
  end
  
  # has a player checked in any actions
  def done_anything_yet?
    self.checkins.count > 0
  end
  
  ### NON-BOOLEAN ATTRIBUTES ###

  def last_completed_budge
    PlayerBudge.where(:program_player_id => self.id).where('stars_final >= ?', 1).order('last_completed_date desc').first
  end

  def last_completed_date
    last_budge = self.player_budges.where('last_completed_date is not null').last
    if last_budge.present?
      return last_budge.last_completed_date  
    else
      return nil
    end
  end
  def coach_username
    if program_coach = self.program_coach
      if program_coach.primary_oauth_token.present?
        return coach_user.primary_oauth_token.remote_username
      else
        return OauthToken.budge_token.remote_username      
      end
    else
      return nil
    end
  end
  
  # active = self.active?
  # playing (has player_budge_id set, no restart_at set)
  # scheduled: start_date is in the future, active = false, stars_final is null
  # in progress: player_budge_id is set, player_budge.start_date is in the past, player_budge.restart_date is not set
  # completed: stars_final = 0-3
  def program_status
    if self.victorious != nil
      if self.victorious? 
        return :victorious
      else
        return :defeated
      end
    elsif self.needs_to_choose_another_budge?
      return :needs_to_choose_another_budge
    elsif self.needs_contact_info? 
      return :needs_contact_info    
    elsif self.player_budge.time_up?
      return :time_up
    elsif self.player_budge.needs_reviving?
      return :needs_reviving
    elsif self.player_budge.ready_to_start?
      return :ready_to_start
    elsif self.player_budge.scheduled?
      return :scheduled
    elsif self.player_budge.caught_up?
      return :caught_up
    else
      return :playing
    end
  end

  # Outcome codes in player_budge.rb
  def status_for_player
    if self.program.blank?
      return "You don't have this program."
    elsif self.needs_to_choose_another_budge?
      return "Choose a level!"
    elsif self.playing?
      return "Check in!"
    elsif self.scheduled?
      return "Scheduled for later."
    elsif self.caught_up?
      return "All caught up!"
    elsif !self.onboarding_complete?
      return "Let's get started!"
    else
      return "Unknown."
    end
  end

  def player_to_coach_bucket
    flag = self.coach_flag
    flag ||= 0
    case flag
      when ProgramPlayer::COACH_FLAG_FINE
        if self.needs_to_play_at.blank? or !self.onboarding_complete?
          return 'New'
        elsif self.needs_to_play_at > Time.now.utc-1.day
          return 'Future'
        elsif self.needs_to_play_at > Time.now.utc-3.days
          return '0-3'
        elsif self.needs_to_play_at > Time.now.utc-7.days
          return '4-7'
        elsif self.needs_to_play_at > Time.now.utc-14.days
          return '8-14'
        else
          return '15+'
        end
      when ProgramPlayer::COACH_FLAG_DANGER
        return 'Danger'
      when ProgramPlayer::COACH_FLAG_LOST
        return 'Lost'
      when ProgramPlayer::COACH_FLAG_DROPPED
        return 'Dropped'
      when ProgramPlayer::COACH_FLAG_RECOVERED
        return 'Recovered'
    end
  end
  
  def unique_checkin_dates(date = Date.today, last_x_days = 30)
    return Checkin.unique_checkin_hash(self.checkins, date, last_x_days)
  end

  def total_player_messages
    self.num_messages_to_coach + self.num_messages_from_coach
  end
  
  def latest_player_message
    PlayerMessage.where(:program_player_id => self.id).order('deliver_at DESC').first
  end
  
  def high_score(program_budge_id, score_key = :top_stars)
    if self.score_data.blank?
      return nil
    elsif self.score_data[program_budge_id].blank?
      return nil
    elsif self.score_data[program_budge_id][score_key].blank?
      return 0
    else
      return self.score_data[program_budge_id][score_key]
    end
  end  

  def recent_checkins(in_past_days=30)
    self.checkins.since(Time.now.in_time_zone(self.user.time_zone_or_default) - in_past_days.day)
  end
  
  # has a player checked in in the last time_amount
  def has_checked_in_last(time_amount=3.day)
    self.checkins.since(Time.now.utc - time_amount).size>0
  end
  
  # has a player checked in any actions
  def done_anything_yet?
    self.checkins.count>0
  end
  
  def was_activated_by(date=Date.today)
    first_checkin=self.checkins.order('created_at').first
    first_checkin.nil? ? false : first_checkin.created_at <= date
  end
  
  # get the player's most recent checkin
  def get_latest_checkin_date
    c=self.checkins.order('created_at').last
    return c.nil? ? nil : c.created_at
  end
        
  ### VERB METHODS ###
  
  # To start a budge
  # 1) end any other budges that they're currently on from this program
  # 2) start new budge (add user_actions, schedule auto_messages)
  def start_budge(program_budge, date = nil, notify = false)
    # Create the new one (puts something things into delayed_jobs)
    if program_budge.present? and program_budge.active?
      # End the current budge, if there is one
      self.end_current_budge(date = nil, notify = false)
    
      program_budge.create_player_budge_for_program_player(self)
    end
  end

  def end_current_budge(date = nil, notify = false)
    if self.player_budge.present?
      self.player_budge.end_player_budge(date = nil, notify = false)
    else 
      return true
    end
  end
    
  # Only run from user.send_nudge_to_lazy_player
  # Assume that they are inactive and need some help getting back on the wagon
  def start_next_recommended_budge
    # Choose the next level to play...
    next_level = self.max_level
    if next_level != 1 
      last_visited = (self.last_visited_at.present? ? self.last_visited_at : self.user.last_logged_in)
      weeks_away = ((Time.zone.now - last_visited)/60/60/24/7).floor
      next_level = next_level - weeks_away
    end
    
    # If they've been away more weeks than their current level number, start scheduling the 
    # budge for a later date (push 1 week out every week they've been gone)
    push_weeks_away = 0
    if next_level < 1
      push_weeks_away = (next_level - 1).abs # subtracting 1 so that we move level 0 to a week away
      next_level = 1        
    end

    if next_level >= self.max_level
      next_level = self.max_level - 1
    end      
    next_program_budge = self.program.next_budge(next_level)
    player_budge = self.start_budge(next_program_budge)
    
    if player_budge.present?
      if push_weeks_away > 0
        player_budge.move_to_day(1, Date.today+(push_weeks_away*7).days)
      end
      # Not doing this any more
      # player_budge.update_attributes(:lazy_scheduled => true) 
    end
    return player_budge
  end
  
  def update_needs_to_play_at(player_budge)
    old_time_zone = Time.zone
    Time.zone = self.user.time_zone_or_default
    # Need to play sometime in the future
    if player_budge.scheduled?
      self.update_attributes(:needs_to_play_at => player_budge.day_starts_at)          
    # Need to play tomorrow
    elsif player_budge.caught_up?
      self.update_attributes(:needs_to_play_at => (Time.zone.now.midnight+1.day).utc)      
    # Need to play now
    else
      self.update_attributes(:needs_to_play_at => (Time.zone.now).utc)          
    end
    Time.zone = old_time_zone
  end
  
  # Assumes payment for the coach was successful
  def buy_coach(new_program_coach, charge = nil, subscription = nil)
    # Cancel the previous subscription, if they have one
    self.end_coach_subscription
  
    self.coach_data ||= Hash.new
    self.coach_user_id = new_program_coach.user_id
    self.program_coach_id = new_program_coach.id
    self.program_coach_subscribed_at = Time.zone.now.to_date
    self.program_coach_subscription_id = (subscription.present? ? subscription.id : nil)
    self.coach_data.merge!({new_program_coach.id => {:user_id => new_program_coach.user_id, 
                                                     :program_coach_id => new_program_coach.id, 
                                                     :charge_id => (charge.present? ? charge.id : nil),
                                                     :subscription_id => (subscription.present? ? subscription.id : nil)}})
    TrackedAction.add(:bought_coach_subscription, self.user)
    result = self.save
    if result 
      self.thanks_for_buying_a_coach
      self.program_coach.delay.update_num_playing
      return true
    else
      return false
    end
  end
  
  def end_coach_subscription(subscription = nil)
    if self.program_coach_subscription_id.present?
      result = Braintree::Subscription.cancel(self.program_coach_subscription_id)
      logger.warn "Canceling subscription: #{self.program_coach_subscription_id}: result: #{result.inspect}"  
    end
    if self.program_coach_id.present?
      TrackedAction.add(:canceled_coach_subscription, self.user)
      self.update_attributes(:program_coach_id => nil,
                             :coach_user_id => nil,
                             :program_coach_subscribed_at => nil,
                             :program_coach_subscription_id => nil)
    end
  end
  
  def post_declaration_to_stream(options = {})
    # declare_end = {:message => "I declare victory/defeat with [program name]",
    #                :private => (params[:entry][:private] == '1'), 
    #                :share_twitter => (params[:entry][:post_to_twitter] == '1'), 
    #                :share_facebook => (params[:entry][:post_to_facebook] == '1')}

    @entry_attributes = {:user_id => self.user_id,
                         :program_id => self.program_id,
                         :program_player_id => self.id,
                         :program_budge_id => nil,
                         :player_budge_id => nil,
                         :parent_id => nil,
                         :location_context_id => (options[:location_context].present? ? options[:location_context].id : nil),
                         :privacy_setting => (options[:private] ? 0 : 10),
                         :message => options[:message],
                         :message_type => 'declare_end',
                         :date => Time.zone.today.to_date,
                         :post_to_coach => true,
                         :post_to_twitter => options[:share_twitter],
                         :post_to_facebook => options[:share_facebook]}

    @existing_entry = Entry.where(:user_id => self.user_id,
                                  :program_player_id => self.id,
                                  :message_type => 'declare_end',
                                  :date => Time.zone.today.to_date).first
    if @existing_entry
      @existing_entry.update_attributes(@entry_attributes)
      @existing_entry.save_metadata
      @existing_entry.post_remotely
    else
      @entry = Entry.create(@entry_attributes)
    end
      
  end
  
  def thanks_for_purchasing
    if self.user.can_email?
      self.user.contact_them(:email, :welcome_to_program, self.program)
    end
  end

  def thanks_for_starting
    if self.user.can_email?
      self.user.contact_them(:email, :welcome_to_program_play, self.program)
    end
  end

  def thanks_for_buying_a_coach
    if self.user.can_email? and self.program_coach.present?
      self.user.contact_them(:email, :welcome_to_program_coach, self)
      self.program_coach.user.contact_them(:email, :new_coachee, self)
    end
  end

  def calculate_num_invites
    self.num_invites_available = 0
    level_counts = Hash.new(0)

    # Go through each completed player budge that wasn't ended early
    self.player_budges.each do |player_budge|
      next if player_budge.ended_early? or !player_budge.passed? or player_budge.program_budge.blank?
      player_budge_level = player_budge.program_budge.level
      level_counts[player_budge_level] += 1
      if level_counts[player_budge_level] == 1
        if player_budge_level == self.program.last_level
          self.num_invites_available += 5 # Extra 5 for completing the last level
        else
          self.num_invites_available += 2       
        end      
      else
        self.num_invites_available += 1
      end
    end
        
    # Save num invites
    self.num_invites_available = 5 if self.num_invites_available > 5
    self.update_attributes(:num_invites_available => self.num_invites_available)
    if self.num_invites_available > 0
      self.user.contact_them(:email, :rewarded_invites, self)
    end
  end
  
  def update_invite_counts
    self.update_attributes(:num_invites_sent => Invitation.where(:program_player_id => self.id).count,
                           :num_invites_viewed => Invitation.where(:program_player_id => self.id, :visited => true).count,
                           :num_invites_accepted => Invitation.where(:program_player_id => self.id, :signed_up => true).count)
  end
  
  def leader_neighbors(up = 1, down = 1)
    @relationship_ids = self.user.relationships.select(:followed_user_id).where(:invisible => false).map{|r|r.followed_user_id}
    
    @two_up = nil
    @one_up = nil
    @one_down = nil

    @utc_date = Time.now.utc.to_date
    @my_score = Leader.where(:program_id => self.program.id, :date => @utc_date, :user_id => self.user.id).first 
    @my_score = self.update_leaderboard_score if @my_score.blank?
    
    # Look for friends first
    if @relationship_ids.present?
      if @my_score.present?
        @two_leaders_up = Leader.where(:program_id => self.program.id, :date => @utc_date).
                            where(['user_id IN (?) AND score > ?', @relationship_ids, @my_score.score]).
                            order('score').limit(2)
        @two_leaders_down = Leader.where(:program_id => self.program.id, :date => @utc_date).
                              where('user_id IN (?) AND score < ?', @relationship_ids, @my_score.score).
                              order('score desc').limit(2)
        
        # Sort them in the right order
        if self.program.leaderboard_trait.present?
          if Leader.direction_token(self.program.leaderboard_trait_direction) == :max
            @one_up = @two_leaders_up.shift
            @two_up = @two_leaders_up.shift
            @one_down = @two_leaders_down.shift
          else
            @one_up = @two_leaders_down.shift
            @two_up = @two_leaders_down.shift
            @one_down = @two_leaders_up.shift
          end
        else
          @one_up = @two_leaders_up.shift
          @two_up = @two_leaders_up.shift
          @one_down = @two_leaders_down.shift
        end
      end
    end
    
    # Look for any user next
    if !@one_up or !@one_down
      if !@leader_up
        @two_leaders_up = Leader.where(:program_id => self.program.id, :date => @utc_date).
                            where(['score > ?', @my_score.score]).
                            order('score').limit(2)
      end
      if !@leader_down
        @two_leaders_down = Leader.where(:program_id => self.program.id, :date => @utc_date).
                              where(['score < ?', @my_score.score]).
                              order('score desc').limit(2)      
      end
      # Sort them in the right order
      if self.program.leaderboard_trait.present?
        if Leader.direction_token(self.program.leaderboard_trait_direction) == :max
          @one_up = @two_leaders_up.shift
          @two_up = @two_leaders_up.shift
          @one_down = @two_leaders_down.shift
        else
          @one_up = @two_leaders_down.shift
          @two_up = @two_leaders_down.shift
          @one_down = @two_leaders_up.shift
        end
      else
        @one_up = @two_leaders_up.shift
        @two_up = @two_leaders_up.shift
        @one_down = @two_leaders_down.shift
      end
    end
    return {:up2 => @two_up, :up1 => @one_up, :down => @one_down, :you => @my_score}
  end

  def update_leaderboard_score(date = Time.now.utc.to_date)
    leader = Leader.find_or_initialize_by_program_id_and_user_id_and_date(self.program_id, self.user_id, date)
    unique_dates_hash = self.unique_checkin_dates(date, 30)
    leader.num_days = unique_dates_hash[:num_unique_dates]
    leader.checkin_string = unique_dates_hash[:string]
    
    # Base leaderboard off a particular trait stat
    if self.program.leaderboard_trait.present?
      if leader.num_days > 0
        user_trait = UserTrait.find_by_user_id_and_trait_id(self.user_id, self.program.leaderboard_trait_id) rescue nil
        if user_trait.present?
          summary_results = user_trait.summary_results(date, 30)
          leader.total = summary_results[:total]
          leader.average = summary_results[:average]
          leader.program_status = self.program_status.to_s
          leader.last_played_days_ago = ((Time.now.utc - self.last_visited_at)/60.0/60.0/24).to_i
          
          if self.program.leaderboard_trait_direction == Leader::DIRECTION_TOTAL_MAX or 
            self.program.leaderboard_trait_direction == Leader::DIRECTION_TOTAL_MIN
            leader.score = summary_results[:total]
          elsif self.program.leaderboard_trait_direction == Leader::DIRECTION_FREQUENCY_MAX or 
            self.program.leaderboard_trait_direction == Leader::DIRECTION_FREQUENCY_MIN
            leader.score = leader.num_days
          elsif self.program.leaderboard_trait_direction == Leader::DIRECTION_AVERAGE_MAX or 
            self.program.leaderboard_trait_direction == Leader::DIRECTION_AVERAGE_MIN
            leader.score = summary_results[:average]
          end        
        end
      end
      
    # Just go by number of unique days checked in in last 30 days
    else
      leader.total = leader.num_days
      leader.average = ((leader.num_days/30)*100).to_i/100.0
      leader.program_status = self.program_status.to_s
      leader.last_played_days_ago = ((Time.now.utc - self.last_visited_at)/60.0/60.0/24).to_i      
      leader.score = leader.num_days
    end
    leader.score = 0 if leader.score.blank?
    leader.save
    return leader
  end
  
  ### AFTER FILTERS ###
    
  # Stores the top star score of each program_budge
  def update_score_data(completed_player_budge)
    self.score_data ||= Hash.new
    self.score_data[completed_player_budge.program_budge_id] ||= {:top_stars => 0, :top_points => 0}
    if self.score_data[completed_player_budge.program_budge_id][:top_stars] < completed_player_budge.stars_final
      self.score_data[completed_player_budge.program_budge_id][:top_stars] = completed_player_budge.stars_final
    end
    self.save
  end

  ### DASH HELPERS ###
  
  # get the program player's current state
  # similar to the concept of user.get_state
  # possible states are:
  # {interested, no programs, no actions, completed, engaged, scheduled, level limbo, off-wagon}
  # @return [String] name of player state
  STATES = ['no actions', 'engaged', 'scheduled', 'level limbo', 'off-wagon', 'long-lost','completed']
  def get_state
    state='unknown'
    if not self.done_anything_yet?
      state='no actions'
    elsif self.completed?
      state='completed'
    elsif self.engaged?
      state='engaged'
    elsif self.scheduled_within(7.day)
      state='scheduled'
    elsif self.in_limbo?
      state='level limbo'
    elsif self.is_long_lost?
      state='long-lost'
    else
      state='off-wagon'
    end
    return state
  end
  
  def self.get_state_counts_on_cohort(program_player_cohort)
    states={}
    STATES.each{|s| states[s]=0}
    states['total_size']=program_player_cohort.size
    program_player_cohort.each{|pp| states[pp.get_state]+=1}
    return states
  end
  
  # get an array of the messages sent and scheduled by the program back until a set amount of time
  def get_timed_auto_messages(start_time=30.days.ago)
    self.program.auto_messages.where(:user_id=>self.user.id, :created_at=> (start_time .. Time.now)).select{|am|am.timed?}
  end
  
  # get player messages that have/will be sent TO this player 
  def get_messages(start_time=30.day.ago,end_time=7.day.from_now)
    self.player_messages.where(:to_user_id=>self.user_id, :created_at=> (start_time .. end_time)).from_budge.order('deliver_at DESC')
  end
  
  def get_checkins(start_time=30.days.ago)
    self.checkins.where(:created_at=>(start_time .. Time.now)).order(:created_at)
  end
  
  # get the level number from the program_budge id
  def get_level_number(budge_id)
    begin 
      self.program.program_budges.find(budge_id).level
    rescue
      nil
    end 
  end  
end


# == Schema Information
#
# Table name: program_players
#
#  id                            :integer(4)      not null, primary key
#  program_id                    :integer(4)
#  user_id                       :integer(4)
#  player_budge_id               :integer(4)
#  last_visited_at               :datetime
#  needs_coach_at                :datetime
#  created_at                    :datetime
#  updated_at                    :datetime
#  wants_to_change               :string(255)
#  how_badly                     :string(255)
#  success_statement             :string(255)
#  latest_tweet_id               :string(255)
#  active                        :boolean(1)      default(TRUE)
#  coach_note                    :string(255)
#  num_messages_to_coach         :integer(4)      default(0)
#  num_messages_from_coach       :integer(4)      default(0)
#  level                         :integer(4)      default(1)
#  max_level                     :integer(4)      default(1)
#  coach_user_id                 :integer(4)
#  required_answer_1             :text
#  required_answer_2             :text
#  optional_answer_1             :text
#  optional_answer_2             :text
#  restart_at                    :date
#  restart_day_number            :integer(4)
#  onboarding_complete           :boolean(1)      default(FALSE)
#  start_date                    :date
#  coach_data                    :text
#  program_coach_id              :integer(4)
#  score_data                    :text
#  completed                     :boolean(1)      default(FALSE)
#  program_coach_subscription_id :string(255)
#  program_coach_subscribed_at   :date
#  program_coach_rating          :integer(4)
#  program_coach_testimonial     :text
#  program_coach_recommended     :boolean(1)
#  program_coach_rated_at        :datetime
#  needs_to_play_at              :datetime
#  num_supporter_invites         :integer(4)      default(1)
#  coach_flag                    :integer(4)
#  needs_coach_pitch             :boolean(1)      default(TRUE)
#  needs_survey_pitch            :boolean(1)      default(TRUE)
#  testimonial                   :text
#  num_invites_sent              :integer(4)      default(0)
#  num_invites_viewed            :integer(4)      default(0)
#  num_invites_accepted          :integer(4)      default(0)
#  num_invites_available         :integer(4)      default(1)
#  needs_contact_info            :boolean(1)      default(TRUE)
#  hardcoded_reminder_hour       :integer(4)
#  last_checked_in               :datetime
#  victorious                    :boolean(1)
#

