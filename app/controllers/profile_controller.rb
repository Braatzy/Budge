class ProfileController < ApplicationController
  layout 'app'
  before_filter :authenticate_user!, :except => [:id, :f, :t]
  protect_from_forgery :except => [:user_info]
  PER_PAGE = 15
  
  
  def index
    @user = current_user
    load_profile_info
    render :action => :view
  end
  
  def id
    @user = User.find params[:id]
    load_profile_info
    render :action => :view
  end
  
  def export
    @user = current_user
    load_profile_info
    @checkins = @user.checkins
    
    if RUBY_VERSION =~ /^1.8/
      require 'fastercsv'
      @csv_lib = FasterCSV
    else
      require 'csv'
      @csv_lib = CSV
    end
    
    respond_to do |format|
      format.csv do
        render_csv("budge-export-#{Time.now.strftime("%Y%m%d")}")
      end
    end    
  end

  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      request.headers['Pragma'] = 'public'
      request.headers["Content-type"] = "text/plain" 
      request.headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      request.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      request.headers['Expires'] = "0" 
    else
      request.headers["Content-Type"] ||= 'text/csv'
      request.headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end
    render :layout => false
  end

  def f
    @user = User.find_by_facebook_username(params[:id]) || User.find_by_facebook_uid(params[:id])
    load_profile_info
    render :action => :view
  end

  def t
    @user = User.where('lower(twitter_username) = ?', params[:id].downcase).first
    load_profile_info
    render :action => :view
  end
  
  def load_profile_info
    @profile_page = true
    if current_user
      @relationship = Relationship.where(:user_id => current_user.id, :followed_user_id => @user.id, :blocked => false, :invisible => false).first
      @reverse_relationship = Relationship.where(:user_id => @user.id, :followed_user_id => current_user.id, :blocked => false).first
    end
    @last_location_context = LocationContext.where(:user_id => @user.id).order('id DESC').first

    # Following, followed
    @num_following = @user.relationships.where(:invisible => false).size
    @num_followers = @user.followed_by_relationships.where(:invisible => false).size
    
    if current_user and current_user == @user
      @entries = Entry.paginate(:per_page => PER_PAGE, :page => params[:page], 
                                :conditions => ['user_id = ?', @user.id],
                                :order => 'id DESC',
                                :include => [:user, :player_budge])  
    else
      @entries = Entry.paginate(:per_page => PER_PAGE, :page => params[:page], 
                                :conditions => ['user_id = ? AND privacy_setting = ?', @user.id, Entry::PRIVACY_PUBLIC],
                                :order => 'id DESC',
                                :include => [:user, :player_budge])      
    end
  end

  def more_entries
    @user = User.find(params[:user_id])
    if current_user and current_user == @user
      @entries = Entry.paginate(:per_page => PER_PAGE, :page => params[:page], 
                                :conditions => ['user_id = ?', @user.id],
                                :order => 'id DESC',
                                :include => [:user, :player_budge])  
    else
      @entries = Entry.paginate(:per_page => PER_PAGE, :page => params[:page], 
                                :conditions => ['user_id = ? AND privacy_setting = ?', @user.id, Entry::PRIVACY_PUBLIC],
                                :order => 'id DESC',
                                :include => [:user, :player_budge])      
    end
    respond_to do |format|
      format.js
    end
  end

  def settings
  end
  
  def coaching
    @program = Program.find params[:id]
    @program_coach = current_user.program_coaches.where(:program_id => params[:id]).first
  end
  
  def rate_coach
    @program_player = ProgramPlayer.find params[:id]
    @program_coach = @program_player.program_coach if @program_player.present?
    if @program_coach.blank? or @program_player.user_id != current_user.id
      redirect_to :controller => :profile, :action => :user_info, :id => :coaches
      return
    end
    
    if request.post?
      @program_player.attributes = params[:program_player]
      @program_player.save

      TrackedAction.add(:rated_a_coach, current_user)
      flash[:kissmetrics_record] ||= Array.new
      flash[:kissmetrics_record] << {:name => "Rated coach"}

      redirect_to :controller => :profile, :action => :user_info, :id => :coaches
    else
      @program_player.program_coach_rating ||= 5
    end
  end
  
  def toggle_follow
    @user = User.find params[:id]
    @relationship = Relationship.where(:user_id => current_user.id, :followed_user_id => @user.id).first
    
    if @relationship 
      if @relationship.blocked?
        # Do nothing
      elsif @relationship.invisible?
        @relationship.update_attributes({:invisible => false})
        @relationship.notify_followee
      elsif !@relationship.invisible?
        @relationship.update_attributes({:invisible => true, :super_follow => false})
      end
    else
      @relationship = Relationship.create({:user_id => current_user.id,
                                           :followed_user_id => @user.id,
                                           :read => true,
                                           :auto => false,
                                           :invisible => false,
                                           :from => 'site',
                                           :super_follow => true})
      # Contact the followed person to let them know...
      @relationship.notify_followee
    end
    logger.warn @relationship.inspect
    respond_to do |format|
      format.js
    end
  end

  def toggle_pings
    @user = User.find params[:id]
    @relationship = Relationship.where(:user_id => current_user.id, :followed_user_id => @user.id).first
    
    if @relationship 
      if @relationship.super_follow?
        @relationship.update_attributes({:super_follow => false})
      else
        @relationship.update_attributes({:super_follow => true})
      end
    else
      @relationship = Relationship.create({:user_id => current_user.id,
                                           :followed_user_id => @user.id,
                                           :read => true,
                                           :auto => false,
                                           :invisible => false,
                                           :from => 'site',
                                           :super_follow => true})
    end
    render :action => :toggle_follow
  end
    
  def user_info
    @user = current_user
    if params[:redirect_to].present?
      session[:redirect_to] = params[:redirect_to] 
    end
    if params[:id] == 'phone'
      if params[:phone] 
        current_user.update_attributes({:phone => params[:phone]})
        current_user.normalize_phone_number
        current_user.send_phone_verification = true
        flash[:message] = "Look for a text from us in the next 10 minutes."
        logger.warn "saved: #{session[:redirect_to]}"
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings, :phone => :verify
        end
      end

    elsif params[:id] == 'communication_pref'
      if params[:user] 
        params[:user][:get_notifications] = true
        current_user.update_attributes(params[:user])
        flash[:message] = "Got it loud and clear, boss."
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings, :phone => :verify
        end
      end

    elsif params[:id] == 'birthday'
      if params[:user] 
        level_up_credits = TrackedAction.user_has_token(current_user, :verified_birthday) ? 0 : 5
        current_user.update_attributes({:birthday_year => params[:user]["birthday(1i)"],
                                  :birthday_month => params[:user]["birthday(2i)"],
                                  :birthday_day => params[:user]["birthday(3i)"],
                                  :level_up_credits => current_user.level_up_credits+level_up_credits,
                                  :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
        TrackedAction.add(:verified_birthday, current_user)
        if current_user.days_til_birthday.present?
          if current_user.days_til_birthday.blank?
            flash[:message] = "Birthday has been noted. Thanks!"
          elsif current_user.days_til_birthday == 0
            flash[:message] = "Happy birthday!"
          else
            flash[:message] = "Happy birthday in #{current_user.days_til_birthday} days!"          
          end
        end
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end

    elsif params[:id] == 'email'
      if params[:user] and params[:user][:email]
        current_user.update_attributes(:email => params[:user][:email])
        TrackedAction.add(:verified_email, current_user)
        flash[:message] = "Wow, that's a cool email address."
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end
          
    elsif params[:id] == 'time_zone'
      if params[:user] and params[:user][:time_zone]
        level_up_credits = TrackedAction.user_has_token(current_user, :verified_time_zone) ? 0 : 5
        current_user.update_attributes({:time_zone => params[:user][:time_zone],
                                        :level_up_credits => current_user.level_up_credits+level_up_credits,
                                  :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
        TrackedAction.add(:verified_time_zone, current_user)
        flash[:message] = "Wow, is it really #{Time.now.in_time_zone(current_user.time_zone_or_default).strftime('%I%p').gsub(/^0/,'').downcase} over there right now?"

        # Reset wake and bed utc times
        current_user.set_wake_and_bed_utc_times

        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end

    elsif params[:id] == 'name'      
    
      if params[:user] and params[:user][:name]
        current_user.name = params[:user][:name]
        current_user.save
        TrackedAction.add(:changed_name, current_user)
        flash[:message] = "Thanks, #{current_user.name}!"
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end

    elsif params[:id] == 'photo'      
    
      raise params.inspect
      if params[:user] and params[:user][:photo]
        current_user.photo = params[:user][:photo]

        flash[:message] = "Thanks, #{current_user.name}!"
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end
      
    elsif params[:id] == 'gender'      
    
      if params[:user] and params[:user][:gender]
        level_up_credits = TrackedAction.user_has_token(current_user, :verified_gender) ? 0 : 5
        current_user.update_attributes({:gender => params[:user][:gender],
                                  :level_up_credits => current_user.level_up_credits+level_up_credits,
                                  :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
        TrackedAction.add(:verified_gender, current_user)
        flash[:message] = "Thanks!"
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end
      
    elsif params[:id] == 'unit_prefs'      
    
      if params[:user] 
        if params[:user][:distance_units]
          level_up_credits = TrackedAction.user_has_token(current_user, :verified_unit_prefs) ? 0 : 5
          current_user.update_attributes({:distance_units => params[:user][:distance_units],
                                    :level_up_credits => current_user.level_up_credits+level_up_credits,
                                    :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
          TrackedAction.add(:verified_unit_prefs, current_user)
        end
        if params[:user][:weight_units]
          level_up_credits = TrackedAction.user_has_token(current_user, :verified_unit_prefs) ? 0 : 5
          current_user.update_attributes({:weight_units => params[:user][:weight_units],
                                    :level_up_credits => current_user.level_up_credits+level_up_credits,
                                    :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
          TrackedAction.add(:verified_unit_prefs, current_user)
        end
        flash[:message] = "Thanks!"
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end

    elsif params[:id] == 'coaches'
      @program_players = current_user.program_players.where('program_id is not null').select{|p|p.program.present? and p.program.featured?}
      
    elsif params[:id] == 'nag_mode'
      if request.post? and !current_user.nag_mode_is_on? and params[:user_nag_mode].present?
        redirect_to :host => SECURE_DOMAIN, :protocol => 'https://', :controller => :store, :action => :pay, :id => params[:user_nag_mode][:nag_mode_id], :type => :nag_mode, :optional_id => params[:user_nag_mode][:program_id]
        return
      end
      if current_user.nag_mode_is_on? and params[:turn_nag_mode_off].present? and @usn = current_user.user_nag_mode
        @usn.update_attributes(:active => false)
      end

    elsif params[:id] == 'close_account'
      if request.post?
        if params[:get_notifications].present?
          current_user.update_attributes(:get_notifications => (params[:get_notifications] == '1'))
          flash[:message] = "Notifications have been turned #{current_user.get_notifications? ? 'ON.' : 'OFF.'}"
        elsif params[:pause_duration].present?
          pause_til_date = Time.zone.today + params[:pause_duration].to_i.days
          current_user.program_players.each do |program_player|
            if program_player.player_budge.present?
              program_player.player_budge.move_to_day(program_player.player_budge.day_of_budge, pause_til_date)
            end
          end
          flash[:message] = "You're paused until #{pause_til_date.strftime('%A %B %d, %Y')}"
        elsif params[:delete_account].present?
          if !current_user.admin?
            Mailer.message_for_habit_labbers("#{current_user.name} (#{current_user.twitter_username}) closed their account",
                                             "Their last words were: #{params[:final_words] ? params[:final_words] : 'Eerie silence...'}",
                                             current_user).deliver rescue nil
            current_user.close_account_and_destroy_everything
            flash[:message] = "Your account is now closed."
            redirect_to :controller => :home, :action => :logout
            return
          else
            flash[:message] = "You're an admin, you can't close your account. Sorry!"
          end
        end
                  
        if session[:redirect_to].present?
          redirect_to session[:redirect_to]
          session[:redirect_to] = nil
        else 
          redirect_to :controller => :profile, :action => :settings
        end
      end
    end
    
  end
  
end
