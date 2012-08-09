class StreamController < ApplicationController
  layout 'app'
  before_filter :authenticate_user!, :only => [:index, :like, :add_comment]
  PER_PAGE = 15

  def filter
    if params[:filter] == 'everyone'
      session[:filter] = 'everyone' 
    elsif params[:filter] == 'friends'
      session[:filter] = 'friends'
    end
    redirect_to :action => :index  
  end

  def index
    @request_location = true
    @program_players = current_user.active_program_players
    @archived_program_players = current_user.program_players
    @entries = get_entries_for_page(session[:filter], params[:page])

    if session[:filter] != 'everyone' && @entries.blank? then
      redirect_to :action => :filter, :filter => 'everyone'
      return
    end
  end

  def more_entries
    @entries = get_entries_for_page(session[:filter], params[:page])
    respond_to do |format|
      format.js
    end
  end

  def get_entries_for_page( filter = 'friends', page = 1)
    if filter  == 'everyone'
      conditions = ['privacy_setting = ? OR user_id = ?',
                    Entry::PRIVACY_PUBLIC, current_user.id]
    else
      relationship_ids  = current_user.relationships.select(:followed_user_id)
      followers         = relationship_ids.map{ |i| i.followed_user_id }
      conditions = ['(user_id IN (?) AND privacy_setting = ?) OR user_id = ?',
                    followers, Entry::PRIVACY_PUBLIC, current_user.id]
    end

    entries = Entry.paginate( :per_page => PER_PAGE,
                              :page => page,
                              :conditions => conditions,
                              :order => 'id DESC',
                              :include => [:user, :player_budge])
    entries
  end

  def view
    @request_location = true
    @entry = Entry.find params[:id]
    @comments = @entry.comments.sort_by{|e|e.created_at}.reverse if @entry.comments.present?
    @program = @entry.program

    if @entry.metadata.blank?
      @entry.save_metadata
    end

    @viewable = false
    if @entry.privacy_setting == Entry::PRIVACY_PUBLIC    
      @viewable = true
    elsif @entry.user == current_user
      @viewable = true
    elsif current_user and @entry.program_player.present? 
      if @entry.program_player.program_coach.present? and @entry.program_player.program_coach.user == current_user
        @viewable = true
      elsif @entry.program_player.supporters.present? and @entry.program_player.supporters.select{|s|s.user.present? and s.user == current_user}.size > 0
        @viewable = true
      end
    end
  end
  
  def like
    # Load my models
    @entry = Entry.find params[:id]
    
    # Initialize the Entry record first
    @like = Like.where(:user_id => current_user.id, :entry_id => @entry.id).first
    if @like.present?
      @like.destroy
      @added = false
    else
      @like = Like.create({:user_id => current_user.id,
                           :entry_id => @entry.id})
      @added = true
    end

    if @added
      if Rails.env.production?
        @like.delay.notify_entry_user
      else
        @like.notify_entry_user 
      end
    end
    respond_to do |format|
      format.js
    end                             
  end

  def add_comment    
    if params[:latitude].present? and params[:longitude].present?
      @location_context = LocationContext.create({:context_about => 'register_location',
                                                  :user_id => current_user.id,
                                                  :latitude => params[:latitude],
                                                  :longitude => params[:longitude]})
    end
    
    # Load my models
    @entry = Entry.find params[:id]
    
    # Initialize the Entry record first
    @comment = EntryComment.create({:user_id => current_user.id,
                                    :entry_id => @entry.id,
                                    :location_context_id => (@location_context.present? ? @location_context.id : nil),
                                    :message => params[:message]})
    if Rails.env.production?
      @comment.delay.notify_entry_participants
    else
      @comment.notify_entry_participants    
    end
    respond_to do |format|
      format.js
    end
  end

  # Redirect to a notification
  def view_notification
    notification = Notification.find_by_short_id(params[:id])
    session[:via_notification] = notification.id if notification.present?

    # Figure out the time zone to assume the responder is using
    if current_user
      time_zone = current_user.time_zone_or_default
    elsif notification.user.present?
      time_zone = notification.user.time_zone_or_default
    elsif notification.from_user.present?
      time_zone = notification.from_user.time_zone_or_default
    else
      time_zone = 'Pacific Time (US & Canada)'
    end
    time_utc = Time.now.utc

    unless params[:suppress_stats].present?
      # If we don't have a referer for this link, save it now
      # Maybe I should only store it on initial response?  
      if notification.ref_site.blank? and request.referer.present?
          referer_uri = URI.parse(request.referer)
          if referer_uri.host.present?
            notification.attributes = {:ref_site => referer_uri.host, :ref_url => request.referer}
          end
      end

      if !notification.responded? and current_user
        time_in_time_zone = Time.now.in_time_zone(time_zone)
        notification.attributes = {:responded_at => time_utc,
                                   :responded_hour_of_day => time_in_time_zone.hour,
                                   :responded_day_of_week => time_in_time_zone.wday,
                                   :responded_week_of_year => time_in_time_zone.strftime('%W').to_i,
                                   :responded_minutes => (notification.delivered_at.present? ? ((time_utc-notification.delivered_at)/60.0).round : nil),
                                   :total_clicks => notification.total_clicks+1,
                                   :responded => true,
                                   :method_of_response => nil}
        # Increment this method of delivery by 1
        if current_user and notification.expected_response?
          case notification.delivered_via
            when 'email'
              if current_user.contact_by_email_score < 10
                new_score = current_user.contact_by_email_score >= 9 ? 10 : current_user.contact_by_email_score+2
                current_user.update_attributes({:contact_by_email_score => new_score})
              end
            when 'sms'
              if current_user.contact_by_sms_score < 10
                new_score = current_user.contact_by_sms_score >= 9 ? 10 : current_user.contact_by_sms_score+2
                current_user.update_attributes({:contact_by_sms_score => new_score})
              end
            when 'public_tweet'
              if current_user.contact_by_public_tweet_score < 10
                new_score = current_user.contact_by_public_tweet_score >= 9 ? 10 : current_user.contact_by_public_tweet_score+2
                current_user.update_attributes({:contact_by_public_tweet_score => new_score})
              end
            when 'dm_tweet'
              if current_user.contact_by_dm_tweet_score < 10
                new_score = current_user.contact_by_dm_tweet_score >= 9 ? 10 : current_user.contact_by_dm_tweet_score+2
                current_user.update_attributes({:contact_by_dm_tweet_score => new_score})
              end
            when 'robocall'
              if current_user.contact_by_robocall_score < 10
                new_score = current_user.contact_by_robocall_score >= 9 ? 10 : current_user.contact_by_robocall_score+2
                current_user.update_attributes({:contact_by_robocall_score => new_score})
              end
            when 'facebook'
              if current_user.contact_by_facebook_wall_score < 10
                new_score = current_user.contact_by_facebook_wall_score >= 9 ? 10 : current_user.contact_by_facebook_wall_score+2
                current_user.update_attributes({:contact_by_facebook_wall_score => new_score})
              end
            when 'twitter'
              if current_user.contact_by_public_tweet_score < 10
                new_score = current_user.contact_by_public_tweet_score >= 9 ? 10 : current_user.contact_by_public_tweet_score+2
                current_user.update_attributes({:contact_by_public_tweet_score => new_score})
              end
          end
        end
      else
        notification.total_clicks = notification.total_clicks+1

      end
      notification.save
    end

    case notification.for_object
      when 'send_link_resource'
        # Stream
        link_resource = notification.data_object
        redirect_to (link_resource.bitly_url.present? ? link_resource.bitly_url : link_resource.url)

      when 'welcome_to_program'
        # Program
        redirect_to :controller => :play, :action => :program, :id => notification.for_id      
      when 'new_coachee'
        # Program Player
        program_player = ProgramPlayer.find notification.for_id
        redirect_to :controller => :play, :action => :coach_stream, :id => program_player.id      
      when 'welcome_to_program_coach'
        # Program Player
        program_player = ProgramPlayer.find notification.for_id
        redirect_to :controller => :play, :action => :program, :id => program_player.program_id      
      when 'welcome_to_program_play'
        # Program
        redirect_to :controller => :play, :action => :program, :id => notification.for_id      
      when 'gentle_nudge'
        # Stream
        redirect_to :controller => :play, :action => :index
      when 'daily_nudge'
        # ProgramPlayer
        program_player = ProgramPlayer.find notification.for_id
        redirect_to :controller => :play, :action => :program, :id => program_player.program_id
      when 'player_message'
        # View Program
        redirect_to :controller => :play, :action => :program, :id => PlayerMessage.find(notification.for_id).program_player.program_id
      when 'message_to_coach'
        player_message = PlayerMessage.find notification.for_id
        # View PlayerMessages from player who needs help from their coach
        if player_message.program_player.present?
          redirect_to :controller => :play, :action => :coach_stream, :id => player_message.program_player.id        
        else
          redirect_to :controller => :stream, :action => :message, :id => notification.for_id
        end
      when 'message_to_player'
        # View PlayerMessages from player who needs help from their coach
        player_message = PlayerMessage.find notification.for_id
        if player_message.program_player.present?
          redirect_to :controller => :play, :action => :coach_stream, :id => player_message.program_player.id        
        else
          redirect_to :controller => :stream, :action => :message, :id => notification.for_id
        end
      when 'entry_comment'
        # View stream item from player who needs help from their coach
        entry_comment = EntryComment.find notification.for_id rescue nil
        if entry_comment.present?
          redirect_to :controller => :stream, :action => :view, :id => entry_comment.entry_id
        
        # Old link... deprecated on 1/28/2012 by Buster
        else
          entry = Entry.find notification.for_id
          redirect_to :controller => :stream, :action => :view, :id => entry.parent_id
        end
      when 'entry_comment_participant'
        # View stream item from player who needs help from their coach
        entry_comment = EntryComment.find notification.for_id rescue nil
        redirect_to :controller => :stream, :action => :view, :id => entry_comment.entry_id
      when 'player_needs_help'
        # View Players who need help
        redirect_to :controller => :dash, :action => :program_player, :id => notification.for_id
      when 'entry'
        # Someone clicked on a shared entry post
        entry = Entry.find notification.for_id
        if entry.message_type == 'starting_soon'
          redirect_to :controller => :play, :action => :program, :id => entry.program_id        
        elsif entry.message_type == 'comment'
          redirect_to :controller => :stream, :action => :index
        else # checkin, secret, nemesis
          redirect_to :controller => :stream, :action => :view, :id => entry.id
        end   
      when 'invite_to_support'
        # Someone clicked on an invite to support
        supporter = Supporter.find notification.for_id
        redirect_to :controller => :home, :action => :support, :id => supporter.id
      when 'invitation_to_program'
        # Someone clicked on an invitation to a particular program
        invitation = Invitation.find notification.for_id
        redirect_to :protocol => 'https://', :host => SECURE_DOMAIN, :controller => :store, :action => :program, :id => invitation.program_player.program.token, :invitation_id => invitation.id   
      when 'invitation_to_program_success'
        # Someone clicked on an invitation to a particular program
        invitation = Invitation.find notification.for_id
        redirect_to :controller => :invite, :action => :program, :id => invitation.program_player.program.id
      when 'completed_level'
        # Player budge -> pick a new level
        player_budge = PlayerBudge.find notification.for_id
        redirect_to :controller => :play, :action => :program, :id => player_budge.program_player.program_id
      when 'coached_player_checked_in'
        # Player budge -> pick a new level
        if notification.message_data[:data].class.to_s == 'Entry'
          entry = Entry.find notification.for_id
          redirect_to :controller => :play, :action => :coach_stream, :id => entry.program_player_id        
        # For notifications of this type that are older than 1/18/2012
        else
          player_budge = PlayerBudge.find notification.for_id
          redirect_to :controller => :play, :action => :coach_stream, :id => player_budge.program_player_id
        end
      when 'coach_batch_report'
        # User
        redirect_to :controller => :coach, :action => :index
      when 'nag'
        # User
        redirect_to :controller => :play, :action => :index
      when 'nag_prompt'
        # nag_mode_prompt
        if current_user.present? and user_nag_mode = current_user.user_nag_mode
          redirect_to :controller => :play, :action => :program, :id => user_nag_mode.program_id          
        else
          redirect_to :controller => :play, :action => :index
        end
      when 'robocall_nag_followup'
        # nag_mode_prompt
        if current_user.present? and user_nag_mode = current_user.user_nag_mode
          redirect_to :controller => :play, :action => :program, :id => user_nag_mode.program_id          
        else
          redirect_to :controller => :play, :action => :index
        end
      
      when 'rewarded_invites'
        redirect_to :controller => :invite, :action => :index
      when 'new_follower'
        # Relationship
        relationship = Relationship.find notification.for_id
        redirect_to :controller => :profile, :action => :t, :id => relationship.user.twitter_username
      when 'invite_to_beta_cohort'
        redirect_to :controller => :home, :action => :flag_for_beta, :id => notification.message_style_token
      when 'phone_number_invalid'
        redirect_to :controller => :profile, :action => :settings
      when 'moment_of_truth'
        player_budge = PlayerBudge.find notification.for_id
        redirect_to :controller => :play, :action => :program, :id => player_budge.program_player.program_id
      when 'since_u_been_gone'
        redirect_to :controller => :stream, :action => :index
      when 'good_morning'
        redirect_to :controller => :stream, :action => :index      
      when 'liked_entry'
        like = Like.find(notification.for_id)
        redirect_to :controller => :stream, :action => :view, :id => like.entry_id
      when 'super_follow_checkin'
        redirect_to :controller => :stream, :action => :view, :id => notification.for_id
      else
        raise "Unknown notification type: #{notification.for_object}"
    end
  end
end
