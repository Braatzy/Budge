class PlayController < ApplicationController
  layout 'app'
  before_filter :authenticate_user!, :except => [:index]
  
  def index
    if current_user.blank? or current_user.hasnt_bought_anything_yet?
      redirect_to :controller => :store
    else
      redirect_to :controller => :stream
    end    
  end
  
  def archives
    if current_user.blank? or current_user.hasnt_bought_anything_yet?
      redirect_to :controller => :store
    else
      @program_players = current_user.program_players.where('program_id is not null and victorious is not null').order('updated_at desc')
      @program_players.delete_if{|p|p.program.blank? or !p.program.featured?} if @program_players.present?
      @todays_date = Time.zone.today.to_date
    end    
  end
  
  def too_many_programs
    @active_program_players = current_user.active_program_players
    unless @active_program_players.size > User::NUM_ACTIVE_PROGRAMS_AT_ONCE
      redirect_to :controller => :stream, :action => :index
    end
  end
  
  def program
    @program = Program.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program).first
    flash.keep

    # If they don't own this program yet
    if @program_player.blank?
      redirect_to :controller => :store, :action => :program, :id => @program.token
      return      
    else
      @program_player.update_attributes(:last_visited_at => Time.now.utc)
    end

    program_status = @program_player.program_status

    if program_status == :needs_contact_info and @program_player.player_budge.present?
      redirect_to :controller => :play, :action => :onboard_contact_info, :id => @program_player.player_budge.id
    
    # If they need to onboard
    elsif program_status == :needs_to_choose_another_budge
      redirect_to :controller => :play, :action => :choose_best_budge, :id => @program.id
  
    # But it's too late to play it... end it and start the next recommended budge
    # day_of_budge = -1 means that we need to restart them in the best level
    elsif program_status == :time_up or program_status == :needs_reviving
      redirect_to :controller => :play, :action => :end_and_start_budge, :id => @program_player.player_budge_id
      
    elsif program_status == :ready_to_start
      redirect_to :controller => :play, :action => :unpause_player_budge, :id => @program_player.player_budge_id 

    # It's set to start in the future
    elsif program_status == :scheduled
      if params[:skip] == 'next'
        redirect_to :controller => :stream, :action => :index
      else
        redirect_to :controller => :play, :action => :next, :program_player_id => @program_player.id
      end

    # If they're all caught up
    elsif program_status == :caught_up
      redirect_to :controller => :play, :action => :checkin, :id => @program.id, :date => Time.zone.today.to_date

    # If they're on a level 1 budge
    elsif program_status == :playing or program_status == :needs_onboarding
      redirect_to :controller => :play, :action => :checkin, :id => @program.id
      
    # If they've declared victory or defeat
    elsif program_status == :victorious or program_status == :defeated
      redirect_to :controller => :play, :action => :ended, :id => @program.id
      
    end
  end
  
  def onboard_contact_info
    @user = current_user
    @player_budge = PlayerBudge.find params[:id]
    raise "Can't onboard" unless @player_budge.present?
    @program_player = @player_budge.program_player
    #raise @program_player.hardcoded_reminder_hour.inspect
    @program = @program_player.program
    @request_location = true
  end

  def onboard_coaches
    @user = current_user
    @player_budge = PlayerBudge.find params[:id]
    raise "Can't onboard" unless @player_budge.present?
    @program_player = @player_budge.program_player
    @program_player.update_attributes(:needs_coach_pitch => false)
    @program = @program_player.program
    @request_location = true
  end

  def onboard_interview
    @user = current_user
    @player_budge = PlayerBudge.find params[:id]
    raise "Can't onboard" unless @player_budge.present?
    @program_player = @player_budge.program_player
    @program = @program_player.program
    @request_location = true
  end
  
  def save_interview
    if current_user 
      @program = Program.find params[:id] if params[:id].present?
      @program_player = current_user.program_players.where(:program_id => @program.id).first

      # Time zone
      if params[:time_zone] and current_user.time_zone != params[:time_zone]
        level_up_credits = TrackedAction.user_has_token(current_user, :verified_time_zone) ? 0 : 5
        current_user.update_attributes({:time_zone => params[:time_zone],
                                  :level_up_credits => current_user.level_up_credits+level_up_credits,
                                  :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
        TrackedAction.add(:verified_time_zone, current_user)
        current_user.set_wake_and_bed_utc_times
      end
      
      # Email
      if params[:email] and current_user.email != params[:email]
        level_up_credits = TrackedAction.user_has_token(current_user, :added_email) ? 0 : 5
        current_user.update_attributes({:email => params[:email],
                                  :get_notifications => true,
                                  :level_up_credits => current_user.level_up_credits+level_up_credits,
                                  :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
        TrackedAction.add(:added_email, current_user)
      end

      # Phone number      
      if params[:phone] 
        current_user.phone = params[:phone]
        current_user.get_notifications = true
        if params[:phone] != "0"
          current_user.normalize_phone_number
          current_user.send_phone_verification = true
        end
        current_user.save
      end
      
      # Set the program player up
      if params[:save_interview]
        @program_player.attributes = {:program_id => @program.id,
                                      :user_id => current_user.id,
                                      :needs_survey_pitch => false}
        TrackedAction.add(:filled_out_onboarding_interview, current_user)
        @program_player.save
      elsif params[:save_hardcoded_hour]
        @program_player.update_attributes(:hardcoded_reminder_hour => params[:hardcoded_reminder_hour],
                                          :needs_contact_info => false)
      end

      # Save simpleGeo context
      if params[:latitude].present? and params[:longitude].present?
        location_context = LocationContext.find_or_initialize_by_context_about_and_context_id('program_player', @program_player.id)
        location_context.update_attributes({:user_id => current_user.id,
                                            :latitude => params[:latitude],
                                            :longitude => params[:longitude]})
                                           
        p "SIMPLEGEO : metro: #{location_context.population_density}, temperature: #{location_context.temperature_f}, weather: #{location_context.weather_conditions}"
      end
    end
    render :text => ''
  end  
  
  def coach_detail
    @program_coach = ProgramCoach.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program_coach.program_id).first
  end
  
  def self_coaching
  end
  
  def onboarding_complete
    @program = Program.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program).first

    # If they don't own this program yet
    if @program_player.blank?
      redirect_to :controller => :store, :action => :program, :id => @program.token
      return
    
    else
      @program_player.update_attributes({:onboarding_complete => true, 
                                         :start_date => Time.zone.today})
      @program_player.thanks_for_starting
      @player_budge = @program_player.start_budge(@program.first_budge)
      redirect_to :controller => :play, :action => :program, :id => @program.id
      return
    end      
  end
  
  def pause
    @player_budge = PlayerBudge.find params[:id]
    @program_player = @player_budge.program_player
    @program = @player_budge.program_budge.program
    raise "Not allowed" unless current_user == @program_player.user  
  end
  
  def reschedule_player_budge
    @player_budge = PlayerBudge.find params[:id]
    @program_player = @player_budge.program_player
    @program = @player_budge.program_budge.program
    raise "Not allowed" unless current_user == @program_player.user
    
    if params[:player_budge].present? and params[:player_budge][:start_date].present?
      @player_budge.move_to_day(@player_budge.day_of_budge, Date.parse(params[:player_budge][:start_date]))      
    elsif 
      @player_budge.move_to_day(@player_budge.day_of_budge, Date.parse(params[:date]))      
    end
    num_days = (@player_budge.day_starts_at.to_date - Time.zone.today).to_i
    if num_days and num_days > 0 and num_days < 30
      flash[:message] = "See you in #{(@player_budge.day_starts_at.to_date - Time.zone.today).to_i} days!"    
    end 
    redirect_to :controller => :play, :action => :program, :id => @program.id, :skip => :next
  end

  def unpause_player_budge
    @player_budge = PlayerBudge.find params[:id]
    @program_player = @player_budge.program_player
    raise "Not allowed" unless current_user == @program_player.user
    
    @program_player.player_budge.move_to_day(@program_player.player_budge.day_of_budge, Time.zone.today)      
    redirect_to :controller => :play, :action => :program, :id => @program_player.program_id
  end

  def instructions
    @request_location = true
    @player_budge = PlayerBudge.find params[:id]
    @program_player = @player_budge.program_player rescue nil
    @program = @program_player.program
    
    # If they don't own this program yet
    if @program_player.blank?
      redirect_to :controller => :store, :action => :program, :id => @program.token
      return

    elsif @player_budge.blank? 
      redirect_to :controller => :play, :action => :program, :id => @program.id
      return
      
    end       
  end

  def paused
    @request_location = true
    @program = Program.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program).first
    @player_budge = @program_player.player_budge if @program_player.present?
    
    # If they don't own this program yet
    if @program_player.blank?
      redirect_to :controller => :store, :action => :program, :id => @program.token
      return

    elsif @player_budge.blank? or !@player_budge.scheduled?
      redirect_to :controller => :play, :action => :program, :id => @program.id
      return
      
    end       
  end
  
  def schedule_player_budge
    @player_budge = PlayerBudge.find params[:id]
    @program_player = @player_budge.program_player
    @program = @player_budge.program_budge.program
    raise "Not allowed" unless current_user == @program_player.user
  end

  def map
    @program = Program.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program.id).first
    @player_budge = @program_player.player_budge
    
    # If they don't own this program yet
    if @program_player.blank?
      redirect_to :controller => :store, :action => :program, :id => @program.token
      return
    end    
    
    @program_budges = @program.program_budges.order(:level)
    @program_budge_to_state = Hash.new
    @program_budges.each do |program_budge|
      if @player_budge.present? and @player_budge.program_budge_id == program_budge.id
        @program_budge_to_state[program_budge.id] = :playing
      elsif @program_player.max_level >= program_budge.level
        if @program_player.high_score(program_budge.id).present?
          @program_budge_to_state[program_budge.id] = :unlocked_played        
        else
          @program_budge_to_state[program_budge.id] = :unlocked_unplayed
        end
      else
        @program_budge_to_state[program_budge.id] = :locked
      end      
    end
  end
  
  def start_budge
    @program_budge = ProgramBudge.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program_budge.program_id).first
    raise "You don't have this program yet." unless @program_budge.present? and @program_player.present?    
    @program = @program_budge.program
    
    if @program_player.player_budge.blank? 
      @player_budge = @program_player.start_budge(@program_budge)    
    elsif @program_player.player_budge.program_budge_id != @program_budge.id or params[:restart].present?
      @player_budge = @program_player.start_budge(@program_budge)
    end
    
    redirect_to :action => :program, :id => @program.id
  end
  
  def choose_best_budge
    @program = Program.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program.id).first
    raise "not valid" unless @program_player and @program_player.user_id == current_user.id
    
    @player_budge = @program_player.start_next_recommended_budge
    if @player_budge.present?
      redirect_to :controller => :play, :action => :program, :id => @program_player.program_id
    elsif @program_player.completed?
      redirect_to :controller => :play, :action => :ended, :id => @program_player.program_id      
    else
      redirect_to :controller => :play, :action => :map, :id => @program_player.program_id      
    end
  end
  
  def end_and_start_budge
    @player_budge = PlayerBudge.find params[:id]
    raise "not valid" unless @player_budge and @player_budge.program_player.user_id == current_user.id
    
    @player_budge.end_player_budge
    @player_budge.start_recommended_budge(@player_budge.last_completed_date, notify = false)    

    redirect_to :action => :next, :id => @player_budge.id, :date => @player_budge.last_completed_date
  end

  def checkin
    @request_location = true
    @program = Program.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program).first

    # If they don't own this program yet
    if @program_player.blank?
      redirect_to :controller => :store, :action => :program, :id => @program.token
      return

    elsif @program_player.player_budge.blank?
      redirect_to :controller => :play, :action => :map, :id => @program.id
      return

    elsif @program_player.player_budge.scheduled?
      redirect_to :controller => :play, :action => :paused, :id => @program.id
      return

    else
      # Stuff we need
      @program_coach = @program_player.program_coach
      @supporters = @program_player.supporters.where(:active => true)
      @player_budge = @program_player.player_budge
      @day_number = @player_budge.day_of_budge
      @program_budge = @player_budge.program_budge
      @user_actions = @player_budge.user_actions_for_checkin
      @num_user_actions_needing_attention = 0 # See if there are any open actions to complete today
      @num_dont_user_actions = 0 # If there are no open "don'ts", offer only checkin for today
      @user_actions.each do |user_action|
        if !user_action.done?
          @num_user_actions_needing_attention += 1 
          if user_action.dont?
            @num_dont_user_actions += 1
          end
        end
      end
      if @num_user_actions_needing_attention == 0
        redirect_to :action => :end_and_start_budge, :id => @player_budge.id
        return
      end
      # Figure out what date we're answering questions for
      @todays_date = @player_budge.todays_date
      @last_completed_date = @player_budge.last_completed_date
      
      # Budge is all do actions and is past the end date, so it's over
      if @player_budge.days_late > 3
        @budge_is_over = true
      end
      
      # If today is the first day of the budge, we have to use that day
      @current_checkin_date = @todays_date
              
      # If no date passed in, choose yesterday or today to play
      if !@current_checkin_date 
        @current_checkin_date = Time.zone.today.to_date
      end

      if @budge_is_over
        redirect_to :action => :end_and_start_budge, :id => @player_budge.id
        return
      elsif @invalid_date
        redirect_to :action => :program, :id => @program_budge.program_id
        return      
      end
      
      @checkins_hash = Hash.new
      @user_actions.each do |user_action|
        @checkins_hash[user_action.id] ||= Hash.new
        @checkins_hash[user_action.id][:checkins] = user_action.checkins
        @checkins_hash[user_action.id][:todays_checkins] = user_action.checkins.where(:date => @current_checkin_date)
      end
    end    
  end

  def options
    @program = Program.find params[:id]
    @program_player = ProgramPlayer.where(:program_id => @program.id, :user_id => current_user.id).first if @program.present?      
    @player_budge = @program_player.player_budge if @program_player.present? 
    @program_budge = @player_budge.program_budge if @player_budge.present? 
  end
  
  def end
    @program = Program.find params[:id]
    @program_player = ProgramPlayer.where(:program_id => @program.id, :user_id => current_user.id).first if @program.present?      
    @player_budge = @program_player.player_budge if @program_player.present? 
    @program_budge = @player_budge.program_budge if @player_budge.present?   
  end
  
  def declare_end  
    if request.post?
      @program = Program.find params[:id]
      @program_player = ProgramPlayer.where(:program_id => @program.id, :user_id => current_user.id).first if @program.present?      
      @player_budge = @program_player.player_budge if @program_player.present? 
      @program_budge = @player_budge.program_budge if @player_budge.present?   
      @program_player.update_attributes(params[:program_player])
      if @player_budge.present?
        @player_budge.end_player_budge
      end

      # Save this to their stream
      if @program_player.ended? and params[:entry].present?
        if @program_player.victorious?
          message = "I declare victory on #{@program.name}!"
        else
          message = "I declare defeat with #{@program.name}."        
        end
        declare_end = {:message => message,
                       :private => (params[:entry][:private] == '1'), 
                       :share_twitter => (params[:entry][:post_to_twitter] == '1'), 
                       :share_facebook => (params[:entry][:post_to_facebook] == '1')}
        @program_player.post_declaration_to_stream(declare_end)
      end
      redirect_to :controller => :play, :action => :ended, :id => @program.id
    else
      redirect_to :controller => :play, :action => :end, :id => params[:id]    
    end
  end

  def ended
    @program = Program.find params[:id]
    @program_player = ProgramPlayer.where(:program_id => @program.id, :user_id => current_user.id).first if @program.present?      
    @player_budge = @program_player.player_budge if @program_player.present? 
    @program_budge = @player_budge.program_budge if @player_budge.present?   
    
    if !@program_player.ended?
      redirect_to :action => :end, :id => @program.id
    else
      @program_players = ProgramPlayer.where(:program_id => @program.id, :victorious => @program_player.victorious).order('updated_at DESC').limit(20)
    end
  end
  
  def coach_stream
    @program_player = ProgramPlayer.find params[:id]
    @player_budge = @program_player.player_budge
    @program = @program_player.program
    @program_coach = @program_player.program_coach
    @supporters = @program_player.supporters.where(:active => true)
    if (@program_coach.present? and current_user == @program_coach.user) or @supporters.where(:user_id => current_user.id).size > 0
      @is_coach = true
    end

    if @player_budge
      @day_number = @player_budge.day_of_budge
      @duration_in_days = @player_budge.program_budge.duration_in_days
    end

    @player_messages = PlayerMessage.paginate(:per_page => 50, :page => params[:page], 
                          :conditions => ['player_messages.program_player_id = ? AND delivered = ?',
                                           @program_player.id, true],
                          :order => 'deliver_at DESC',
                          :include => [:to_user, :from_user, :program, :player_budge, :entry, :program_budge])
  end
  
  def send_player_message
    @program_player = ProgramPlayer.find params[:id]
    raise "No program player" unless @program_player.present?
    @player_budge = @program_player.player_budge
    @program = @program_player.program
    @program_coach = @program_player.program_coach
    @supporters = @program_player.supporters.where(:active => true)
    
    @to_player = false
    @to_coach = false
    @to_supporters = false
    if @program_player.user_id == current_user.id 
      if @program_coach.present?
        @to_coach = true
      end
      if @supporters.present?
        @to_supporters = true
      end
    else
      @to_player = true
    end
    
    # Determine who needs to be notified of this message
    if @to_coach 
      @to_user = @program_coach.user
    else
      @to_user = @program_player.user
    end

    # The best way to notify the person getting this message
    if @to_user.can_sms?
      @deliver_via_pref = PlayerMessage::SMS   
      @via = :sms 
    elsif @to_user.can_email?
      @deliver_via_pref = PlayerMessage::EMAIL    
      @via = :email
    else
      @deliver_via_pref = PlayerMessage::TWEET_DM
      @via = :dm_tweet
    end

    # Create a new player message
    @player_message = PlayerMessage.create({:from_user_id => current_user.id,
                                            :to_user_id => @to_user.id,
                                            :content => params[:content],
                                            :program_player_id => @program_player.id,
                                            :player_budge_id => (@player_budge.present? ? @player_budge.id : nil),
                                            :deliver_via_pref => @deliver_via_pref,
                                            :delivered_via => @deliver_via_pref,
                                            :delivered => true,
                                            :from_coach => @to_player,
                                            :to_player => @to_player,
                                            :to_coach => @to_coach,
                                            :to_supporters => @to_supporters,                                            
                                            :program_id => @program.id,
                                            :program_budge_id => (@player_budge.present? ? @player_budge.program_budge_id : nil),
                                            :deliver_at => Time.now.utc})

    # Send it to them via sms
    if @to_player
      @player_message.to_user.contact_them(@via, :message_to_player, @player_message)
    else
      if @to_coach
        @player_message.to_user.contact_them(@via, :message_to_coach, @player_message)
      end
      if @to_supporters
        @supporters.each do |supporter|
          # The best way to notify the person getting this message
          if supporter.user.can_sms?
            supporter.user.contact_them(:sms, :message_to_coach, @player_message)
          elsif supporter.user.can_email?
            supporter.user.contact_them(:email, :message_to_coach, @player_message)
          else
            supporter.user.contact_them(:dm_tweet, :message_to_coach, @player_message)
          end        
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  # checkin_hash needs to supply to following info before passing to user_trait
  # | user_id                      | int(11)       | YES  |     | NULL    |                | 
  # | amount_decimal               | decimal(10,2) | YES  |     | NULL    |                | 
  # | amount_integer               | int(11)       | YES  |     | 0       |                | 
  # | amount_string                | varchar(255)  | YES  |     | NULL    |                | 
  # | amount_text                  | text          | YES  |     | NULL    |                | 
  # | date                         | date          | YES  |     | NULL    |                | 
  # | is_player                    | tinyint(1)    | YES  |     | 1       |                | 
  # | trait_id                     | int(11)       | NO   |     | NULL    |                | 
  # | user_trait_id                | int(11)       | NO   |     | NULL    |                | 
  # | latitude                     | int(11)       | YES  |     | NULL    |                | 
  # | longitude                    | int(11)       | YES  |     | NULL    |                | 
  # | checkin_datetime             | datetime      | YES  |     | NULL    |                | 
  # | checkin_datetime_approximate | tinyint(1)    | YES  |     | 0       |                | 
  # | checkin_via                  | varchar(255)  | YES  |     | NULL    |                | 
  # | comment                      | text          | YES  |     | NULL    |                | 
  # | remote_id                    | varchar(255)  | YES  |     | NULL    |                | 
  # ----------------------------------------------------------------------------------------
  # options_hash needs to also have
  # one_per_day :boolean
  def save_checkin
    @user_action = UserAction.find params[:user_action_id]
    @date = params[:date]
    raise "Not allowed" unless @user_action.present? and @user_action.user_id == current_user.id

    # Stuff we'll need
    @player_budge = @user_action.player_budge
    @program_player = @player_budge.program_player
    @program_coach = @program_player.program_coach.present? ? @program_player.program_coach : nil
    @trait = @user_action.trait
    @user_trait = UserTrait.find_or_create_by_trait_id_and_user_id(@trait.id, current_user.id)
  
    @index = params[:index].present? ? params[:index].to_i : 0
    @new_index = @index + 1

    checkin_hash = Hash.new

    # Convert the answer into amount_decimal...    
    # Whether or not they are reporting an action actually happening (versus not happening)
    if params[:answer_type] == 'boolean' 
      if params[:answer] == 'yes'
        checkin_hash[:amount_decimal] = 1
      elsif params[:answer] == 'no'
        checkin_hash[:amount_decimal] = 0
      else
        checkin_hash[:amount_decimal] = nil
      end
    elsif params[:answer_type] == 'text'
      checkin_hash[:amount_decimal] = 1
      checkin_hash[:amount_text] = params[:answer]
      if @trait.past_template.present?
        checkin_hash[:raw_text] = @trait.past_template.gsub("[answer]",params[:answer])
      end
            
    elsif params[:answer_type] == 'number'
      if @trait.answer_type == ':seconds'
        checkin_hash[:amount_text] = params[:answer]
        minutes_seconds = params[:answer].split(/:/)
        if minutes_seconds.size > 1
          checkin_hash[:amount_decimal] = (minutes_seconds[0].to_i*60) + minutes_seconds[1].to_i
        else
          checkin_hash[:amount_decimal] = params[:answer].to_i
        end
      else
        checkin_hash[:amount_decimal] = params[:answer].to_f
      end
    end

    time_in_time_zone = Time.zone.now.in_time_zone(current_user.time_zone_or_default)

    # attributes of the eventual Checkin
    checkin_hash.merge!({:user_id => current_user.id,
                         :date => @date,
                         :is_player => true,
                         :trait_id => @trait.id,
                         :user_trait_id => @user_trait.id,
                         :latitude => params[:latitude],
                         :longitude => params[:longitude],
                         :checkin_datetime => time_in_time_zone,
                         :checkin_datetime_approximate => false,
                         :checkin_via => 'player', 
                         :comment => nil,
                         :remote_id => nil})
                    
    options_hash = {}

    @checkins = @user_trait.save_new_data(checkin_hash, options_hash)
    @user_action.reload

    @checkins_hash = {:checkins => @user_action.checkins,
                      :todays_checkins => @user_action.checkins.where(:date => @date)}
  end 
  
  def delete_checkin
    @checkin = Checkin.find params[:id]
    @date = params[:date]
    @index = params[:index].to_i
    @checkin_id = @checkin.id
    @player_budge = @checkin.player_budge
    @user_action = @checkin.user_action
    if current_user.id == @checkin.user_id
      @checkin.destroy
      if @player_budge and @player_budge.in_progress?
        @player_budge.calculate_stars(final = false)
      end
      if @user_action and @user_action.completed?
        @user_action.schedule_next_day_or_budge(nil, check_for_downgrade = true)
      end
    end
    @checkins_hash = {:checkins => @user_action.checkins, :todays_checkins => @user_action.checkins.where(:date => @date)}
    respond_to do |format|
      format.js
    end
  end
  
  # After they've answered every question, this saves or finalizes the day
  def save_day 
    if params[:latitude].present? and params[:longitude].present?
      #@location_context = LocationContext.create({:context_about => 'register_location',
      #                                            :user_id => current_user.id,
      #                                            :latitude => params[:latitude],
      #                                            :longitude => params[:longitude]})
    end
    @player_budge = PlayerBudge.find params[:player_budge_id]
    @program_player = @player_budge.program_player
    @program_player_status = @program_player.program_status
    @date = Date.parse(params[:date])
    save_day_options = {:date => @date,
                        :notify => false, 
                        :message_type => params[:message_type],
                        :message => params[:message],
                        :location_context => @location_context,
                        :private => (params[:private] == '1'), 
                        :share_twitter => (params[:share_twitter] == '1'), 
                        :share_facebook => (params[:share_facebook] == '1')}
    @saved = @player_budge.save_days_checkin(save_day_options)
    
    if @player_budge.completed? and @program_player.completed? and !@program_player.ended?
      @next_page_url = url_for(:controller => :play, :action => :end, :id => @program_player.program_id)    
    else
      @next_page_url = url_for(:controller => :play, :action => :next, :date => @date, :id => @player_budge.id)
    end
  end
  
  def next
    time_of_day = (Time.zone.now.hour > 15 or Time.zone.now.hour < 7) ? 'evening' : 'morning'
    # The one they just played (even if they've since been moved to a new budge)
    if params[:id]
      @player_budge = PlayerBudge.find params[:id]
      raise "Not your budge" unless @player_budge.present? and @player_budge.program_player.user == current_user
      @program_player = @player_budge.program_player

    # If they didn't just move from a previous budge, just load their program
    elsif params[:program_player_id]
      @program_player = ProgramPlayer.find params[:program_player_id]
      @no_new_player_budge = true
    end  
    
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @program = @program_player.program

    # Figure out leaderboard neighbors
    @leader_neighbors = @program_player.leader_neighbors(1, 1)
    @one_up, @one_down = @leader_neighbors[:up], @leader_neighbors[:down]

    # The one they're currently playing
    @current_player_budge = @program_player.player_budge    
    @now_playing = current_user.program_players.where(['program_id is not null AND needs_to_play_at <= ? AND program_id <> ?', 
                                                 Time.now.utc, @program.id]).delete_if{|p|!p.program.present? or !p.program.featured?}
        
    if @current_player_budge.present?
      if !@player_budge
        @started_playing = true

      elsif @program_player.player_budge.id == @player_budge.id and !@player_budge.completed?
        @still_playing = true
        redirect_to :controller => :stream, :action => :index, :player_budge_id => @player_budge.id
        return
    
      # If they're replaying the same budge
      elsif @current_player_budge.program_budge_id == @player_budge.program_budge_id
        @replaying = 'completed'
        if @player_budge.stars_final.present? 
          if @player_budge.passed?
            @replaying = 'passed'
          elsif @player_budge.stars_final == 0
            @replaying = 'failed'          
          end
        end

      # If they're playing the next level
      elsif @program_player.player_budge.program_budge.level > @player_budge.program_budge.level
        @leveled_up = true
        @next_player_budge = @program_player.player_budge
      end
    else
      # FIXME: Very likely done with this program!
      redirect_to :action => :program, :id => @program.id
    end
  end
  
  def done
    time_of_day = (Time.zone.now.hour > 15 or Time.zone.now.hour < 7) ? 'evening' : 'morning'
    @program = Program.find params[:id] if params[:id].present?
    @program_player = ProgramPlayer.where(:program_id => @program.id, :user_id => current_user.id).first if @program.present?
    if @program_player.present?   
      @player_budge = @program_player.player_budge   
      @program_coach = @program_player.program_coach 
      @supporters = @program_player.supporters.where(:active => true) 
    end
    @now_playing = current_user.program_players.where(['program_id is not null AND needs_to_play_at <= ? AND program_id <> ?', Time.now.utc, @program.id]).delete_if{|p|!p.program.present? or !p.program.featured?}
  end
  
  def byebye
    @program = Program.find params[:id]
  end
  
  def buy_coach
    @program = Program.find params[:id]
    @program_player = ProgramPlayer.where(:program_id => @program.id, :user_id => current_user.id).first 
  end
  def invite_supporter
    @program = Program.find params[:id]
    @program_player = ProgramPlayer.where(:program_id => @program.id, :user_id => current_user.id).first 
    @supporter = Supporter.new
  end
  def create_invite
    @program_player = ProgramPlayer.find params[:id]
    @program = @program_player.program
    @twitter_oauth = current_user.oauth_for_site_token('twitter')
    if @twitter_oauth.present? and params[:supporter].present? and params[:supporter][:user_twitter_username].present? and @relationship = @twitter_oauth.can_dm_username(params[:supporter][:user_twitter_username]) then
      @supporter = Supporter.find_or_initialize_by_program_player_id_and_user_id(@program_player.id, current_user.id)
      @user_info = @twitter_oauth.info_about_username(params[:supporter][:user_twitter_username])
    else
      respond_to do |format|
        format.js
      end      
    end 
  end
  def cancel_supporter
    @supporter = Supporter.find params[:id] rescue nil
    raise "Can't cancel this supporter" if @supporter.blank? or (current_user.id != @supporter.user_id and current_user.id != @supporter.program_player.user_id)
    
    @supporter.destroy
    if params[:redirect_to]
      redirect_to params[:redirect_to]
    else
      redirect_to :controller => :play, :action => :buy_coach, :id => @supporter.program_id
    end
  end
  
  # share_coach => PlayerMessage with to_user
  # share_twitter => post to Twitter
  # share_facebook => post to Facebook
  # create a new Entry record
  def share_message    
    if params[:latitude].present? and params[:longitude].present?
      @location_context = LocationContext.create({:context_about => 'register_location',
                                                  :user_id => current_user.id,
                                                  :latitude => params[:latitude],
                                                  :longitude => params[:longitude]})
    end
    
    # Load my models
    @program = Program.find(params[:program_id]) if params[:program_id]
    @program_player = ProgramPlayer.find(params[:program_player_id]) if params[:program_player_id]
    @player_budge = PlayerBudge.find(params[:player_budge_id]) if params[:player_budge_id]
    raise "PlayerBudge.program_player_id doesn't match ProgramPlayer.id" if @player_budge.present? and @program_player.present? and @player_budge.program_player_id != @program_player.id
    @entry = Entry.find(params[:entry_id]) if params[:entry_id].present?
    
    if current_user.id == @program_player.user_id
      if params[:message].blank?
        if params[:message_type] == 'share_message'
          params[:message] = "I'm playing this awesome game called #{@program.name}! Check it out!"
        elsif params[:message_type] == 'checkin'
          params[:message] = "I've made progress on #{@program.name}. Check it out!"      
        end
      end
    else
      if params[:message].blank?
        if params[:message_type] == 'comment'
          params[:message] = "This is good."
        end
      end    
    end
    
    # Initialize the Entry record first
    @entry = Entry.create({:user_id => current_user.id,
                           :program_id => @program.id,
                           :program_player_id => params[:program_player_id],
                           :program_budge_id => (@player_budge.present? ? @player_budge.program_budge_id : nil),
                           :player_budge_id => (@player_budge.present? ? @player_budge.id : nil),
                           :parent_id => (@entry.present? ? @entry.id : nil),
                           :location_context_id => (@location_context.present? ? @location_context.id : nil),
                           :message => params[:message],
                           :message_type => params[:message_type],
                           :date => Time.zone.today.to_date,
                           :post_to_coach => params[:post_to_coach],
                           :post_to_twitter => params[:post_to_twitter],
                           :post_to_facebook => params[:post_to_facebook]})
                           
    @done_page_token = params[:message_type]
  end
  
  def send_invite
    @program_player = ProgramPlayer.find params[:id]
    if @program_player.num_supporter_invites > 0
      if params["user_twitter_username"].present?
        @existing_supporter = Supporter.where(:program_player_id => @program_player.id, :user_twitter_username => params['user_twitter_username']).first
        supporter = @existing_supporter || Supporter.create({:program_player_id => @program_player.id,
                                                :program_id => @program_player.program_id,
                                                :active => false,
                                                :user_twitter_username => params[:user_twitter_username].downcase,
                                                :user_name => params[:user_name],
                                                :invite_message => params[:invite_message]})
        if supporter.deliver_invite
          @program_player.update_attributes(:num_supporter_invites => @program_player.num_supporter_invites-1)
          @message = "Invite sent!"
        else
          @message = "Trouble sending invite. Please try again."
        end
      else
        @message = "Please supply a Twitter username."
      end
    else
      @message = "You don't have any more invites left."
    end
    flash[:message] = @message
    respond_to do |format|
      format.js
    end
  end
  
  def supporter_detail
    @supporter = Supporter.find params[:id]
    @program_player = @supporter.program_player
    @program = @supporter.program
    raise "Not allowed." unless current_user == @program_player.user
  end
  
  # Run once and delete before running migrations
  def delete_duplicate_program_players_and_user_traits
    @program_players = ProgramPlayer.order(:id)
    
    @user_to_program = Hash.new
    @program_players.each do |program_player|
      @user_to_program[program_player.user] ||= Hash.new
      @user_to_program[program_player.user][program_player.program] ||= Array.new
      @user_to_program[program_player.user][program_player.program] << program_player
    end
    
    @user_to_program.each do |user, program_hash|
      if program_hash.size > 1
        program_hash.each do |program, program_players|
          latest_program_player = nil
          program_players.reverse.each_with_index do |program_player, index|
            next unless program_player.program.present?
            if index == 0
              logger.warn "keeping #{program_player.id}"  
              latest_program_player = program_player            
            else
              logger.warn "deleting #{program_player.id} (replacing it with #{latest_program_player.id})"
              PlayerBudge.update_all(['program_player_id = ?', latest_program_player.id], ['program_player_id = ?', program_player.id])
              PlayerNote.update_all(['program_player_id = ?', latest_program_player.id], ['program_player_id = ?', program_player.id])
              PlayerMessage.update_all(['program_player_id = ?', latest_program_player.id], ['program_player_id = ?', program_player.id])
              
              program_player.destroy
            end
          end
        end
      end
    end



    @user_traits = UserTrait.order(:id)
    
    @user_to_trait = Hash.new
    @user_traits.each do |user_trait|
      @user_to_trait[user_trait.user] ||= Hash.new
      @user_to_trait[user_trait.user][user_trait.trait] ||= Array.new
      @user_to_trait[user_trait.user][user_trait.trait] << user_trait
    end
    
    @user_to_trait.each do |user, trait_hash|
      if trait_hash.size > 1
        trait_hash.each do |trait, user_traits|
          latest_user_trait = nil
          user_traits.reverse.each_with_index do |user_trait, index|
            if user_trait.trait.present?
              if index == 0
                logger.warn "keeping user_trait #{user_trait.id}"  
                latest_user_trait = user_trait            
              else
                logger.warn "deleting user_trait #{user_trait.id} (replacing it with #{latest_user_trait.id})"
                user_trait.destroy
              end
            else
              user_trait.destroy
            end
          end
        end
      end
    end
  end
end
