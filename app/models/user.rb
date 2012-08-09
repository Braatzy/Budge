require 'open-uri'

class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :oauth2_providable, 
           :oauth2_password_grantable,
           :oauth2_refresh_token_grantable,
           :oauth2_authorization_code_grantable
    
    # Setup accessible (or protected) attributes for your model
    attr_accessible :password, :password_confirmation, :remember_me
    attr_accessible :name, :email, :phone, :time_zone, :photo, :photo_file_name, :photo_content_type, :photo_file_size, :gender, :birthday_day, :birthday_month, :birthday_year, :email_verified, :get_notifications, :get_news, :no_notifications_before, :no_notifications_after, :last_logged_in, :use_metric, :bio, :facebook_uid, :admin, :relationship_status, :level_up_credits, :num_notification, :total_level_up_credits_earned, :meta_level, :phone, :phone_normalized, :phone_verified, :facebook_username, :twitter_username, :contact_by_email_pref, :contact_by_sms_pref, :contact_by_public_tweet_pref, :contact_by_dm_tweet_pref, :contact_by_robocall_pref, :contact_by_email_score, :contact_by_sms_score, :contact_by_public_tweet_score, :contact_by_dm_tweet_score, :contact_by_robocall_score, :send_phone_verification, :phone_normalized, :phone_verified, :contact_by_facebook_wall_pref, :contact_by_facebook_wall_score, :contact_by_friend_pref, :contact_by_friend_score, :visit_streak, :meta_level_alignment, :meta_level_role, :meta_level_name, :addon_cache, :coach, :visit_stats_updated, :visit_stats_sample_size, :streak_level, :has_braintree, :distance_units, :weight_units, :currency_units, :withings_user_id, :withings_public_key, :withings_username, :withings_subscription_renew_by, :last_latitude, :last_longitude, :lat_long_updated_at, :next_nudge_at, :in_beta, :last_location_context_id, :dollars_credit, :send_phone_verification, :status, :officially_started_at, :cohort_tag, :invited_to_beta, :cohort_date, :wake_hour_utc, :bed_hour_utc

    # From http://docs.heroku.com/s3
    has_attached_file :photo, 
      :styles => {:large => "800x800>", 
                  :medium => "300x300>", 
                  :small => "75x75#", 
                  :tiny => "30x30#"},
      :storage => :s3, 
      :s3_credentials => "#{Rails.root}/config/s3.yml", 
      :path => "/:class/:attachment/:id/:style_:basename.:extension",
      :url => "/:class/:attachment/:id/:style_:basename.:extension",
      :bucket => 'budge_production',
      :default_url => "missing.jpg"

    # From http://www.aidanf.net/rails_user_authentication_tutorial
    # validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email address" 
    # validates_length_of :username, :within => 3..40
    # validates_uniqueness_of :username, :case_sensitive => false
    # validates_format_of :username, :with => /^[\.\w_-]+$/i, :message => "can only contain letters, numbers, and periods (.)."
    # validates_format_of :phone,
    #                    :message => "must be a valid telephone number.",
    #                    :with => /(^[\(\)0-9\- \+\.]{10,20}$|^$)/  

    belongs_to :last_location_context, :class_name => 'LocationContext'
    has_many :oauth_tokens, :dependent => :destroy
    has_many :relationships, :dependent => :destroy
    has_many :followed_by_relationships, :class_name => 'Relationship', :foreign_key => :followed_user_id, :dependent => :destroy
    has_many :tracked_actions
    has_many :user_actions, :dependent => :destroy
    has_many :sent_user_actions, :foreign_key => 'budger_user_id', :class_name => 'UserAction'
    has_many :user_traits, :dependent => :destroy
    has_many :checkins, :dependent => :destroy
    has_many :user_addons, :include => [:addon]
    has_many :addons, :through => :user_addons, :dependent => :destroy
    has_many :program_players, :dependent => :destroy
    has_many :programs, :through => :program_players
    has_many :location_contexts, :dependent => :destroy
    has_many :program_coaches, :dependent => :destroy
    has_many :twitter_scores, :dependent => :destroy, :foreign_key => 'twitter_screen_name', :primary_key => 'twitter_username'
    has_many :supporting, :class_name => 'Supporter', :dependent => :destroy
    has_many :invitations, :dependent => :destroy
    has_many :notifications
    has_many :leaders, :dependent => :destroy
    has_many :user_nag_modes, :dependent => :destroy
    before_create :set_them_up_with_some_dolla_dolla_bills, :set_cohort_date
    after_create :set_wake_and_bed_utc_times
    
    serialize :addon_cache
    
    scope :began_budging, lambda {|timestamp_start,timestamp_stop| {:conditions => {:created_at => (timestamp_start .. timestamp_stop)}}}
    
    DOLLARS_ON_SIGNUP = 0
    DOLLARS_CREDIT_FOR_BEING_INVITED = 5 # To the person invited
    DOLLARS_ON_SIGNUP_WHEN_INVITED = DOLLARS_ON_SIGNUP + DOLLARS_CREDIT_FOR_BEING_INVITED

    # Goes to the person who did the inviting
    DOLLARS_CREDIT_FOR_INVITE = 0 
    
    NUM_ACTIVE_PROGRAMS_AT_ONCE = 3
    
    def set_cohort_date
      self.cohort_date = Time.now.utc.beginning_of_week unless self.cohort_date.present?
    end

    def set_them_up_with_some_dolla_dolla_bills
      self.dollars_credit = DOLLARS_ON_SIGNUP # Everyone gets $X for signing up
    end
    
    def first_name
      self.name.match(/\w+/).to_s    
    end
    
    def update_profile_photo
      self.photo = open("http://api.twitter.com/1/users/profile_image/#{self.twitter_username}?size=original") rescue nil
      self.save
    end
    
    DISTANCE_UNITS = {0 => {:short => 'mi', :long => 'mile'}, 1 => {:short => 'km', :long => 'kilometer'}}
    WEIGHT_UNITS = {0 => "lbs", 1 => "kgs"}
    CURRENCY_UNITS = {0 => "dollars", 1 => "pounds", 2 => 'euro'}
    
    def weight_pref
      if self.weight_units.blank?
        return WEIGHT_UNITS[0]
      else
        return WEIGHT_UNITS[self.weight_units]
      end
    end

    def distance_pref(size = :long)
      if self.distance_units.blank?
        return DISTANCE_UNITS[0][size]
      else
        return DISTANCE_UNITS[self.distance_units][size]
      end
    end
    
    SITE_TOKENS_POSSIBLE=['twitter','foursquare','facebook','fitbit','runkeeper']

    def list_accounts_connected
      accounts=SITE_TOKENS_POSSIBLE.select{|site| site unless self.oauth_for_site_token(site).blank?}
      accounts.push('withings') unless withings_user_id.blank?
      return accounts.join(', ')
    end

    
    # Get the first oauth_token for this site
    def oauth_for_site_token(site_token)
      ot = self.oauth_tokens.where(:site_token => site_token, :primary_token => true)
      if ot.blank?    
        return nil
      else
        return ot.first
      end
    end

    # Get ALL oauth_tokens for a given user and site_token 
    def oauths_for_site_token(site_token)
      ot = self.oauth_tokens.where(:site_token => site_token)
      if ot.blank?    
        return nil
      else
        return ot
      end
    end
    
    def latest_twitter_score
      ot = self.oauth_for_site_token('twitter')
      return TwitterScore.where(:twitter_id => ot.remote_user_id).order('id DESC').first
    end
    
    def current_location_context_guess
      if self.last_latitude.present? and self.last_longitude.present?
        return OauthToken.simplegeo_context(self.last_latitude, self.last_longitude)
      else
        return nil
      end
    end
    
    def username
      if self.twitter_username.present?
        return self.twitter_username
      elsif self.facebook_username.present?
        return self.facebook_username
      end
    end
    
    def birthday
      if self.birthday_day.present? and self.birthday_month.present? and self.birthday_year.present?
        return Date.parse("#{self.birthday_year}-#{self.birthday_month}-#{self.birthday_day}")
      else
        return nil
      end
    end
    
    def days_til_birthday
      if self.birthday.present?
        return (365 -((Date.today - self.birthday).to_i % 365))
      else
        return nil
      end
    end
    
    def hasnt_bought_anything_yet?
      self.get_program_players.blank?    
    end
        
    def is_off_hours?(time_now = nil)
      time_now ||= Time.now.in_time_zone(self.time_zone_or_default)
      if time_now.hour >= self.no_notifications_before and
        time_now.hour < self.no_notifications_after
        return false
      else
        return true
      end
    end
    
    # Program Players that have a program and are featured in the store
    def valid_program_players
      if program_players.present?
        self.program_players.delete_if{|p|p.program.blank? || !p.program.featured?}     
      else
        return []
      end
    end

    # Program Players that have a program and are featured in the store
    def active_program_players
      if program_players.present?
        self.program_players.delete_if{|p|p.program.blank? || !p.program.featured? || p.ended?}     
      else
        return []
      end
    end

    # Program Players that have a program and are featured in the store
    def archived_program_players
      if program_players.present?
        self.program_players.delete_if{|p|p.program.blank? || !p.program.featured? || !p.ended?}     
      else
        return []
      end
    end
    
    def time_zone_or_default
      self.time_zone.blank? ? "Pacific Time (US & Canada)" : self.time_zone
    end
    
    def self.select_options_for_hours_of_day
      [['1am',1],['2am',2],['3am',3],['4am',4],['5am',5],['6am',6],['7am',7],['8am',8],['9am',9],['10am',10],['11am',11],['noon',12],
       ['1pm',13],['2pm',14],['3pm',15],['4pm',16],['5pm',17],['6pm',18],['7pm',19],['8pm',20],['9pm',21],['10pm',22],['11pm',23],['midnight',24],['1am',25],['2am',26],['3am',27],['4am',28]]
    end
    
    def self.select_options_for_contact_pref
      [['LOVE', 10], ['really like', 8], ['am okay with', 5], ['dislike', 3], ['sorta hate', 0]]
    end
    
    def can_dm_tweet?
      self.contact_by_dm_tweet_pref > 0
    end
    def can_public_tweet?
      self.contact_by_public_tweet_pref > 0
    end
    def can_email?
      self.email.present? and self.contact_by_email_pref > 0 #and self.email_verified?
    end
    def can_sms?    
      if self.phone and self.phone_verified? and self.contact_by_sms_pref > 0
        time_in_time_zone = Time.now.in_time_zone(self.time_zone_or_default)
        if time_in_time_zone.hour >= self.no_notifications_before and time_in_time_zone.hour < self.no_notifications_after
          return true
        else
          return false
        end
      else
        return false
      end
    end
    def can_robocall?    
      if self.phone and self.phone_verified? and self.contact_by_robocall_pref > 0
        time_in_time_zone = Time.now.in_time_zone(self.time_zone_or_default)
        if time_in_time_zone.hour >= self.no_notifications_before and time_in_time_zone.hour < self.no_notifications_after
          return true
        else
          return false
        end
      else
        return false
      end
    end
    
    # Create a weighted hash of ways to contact this person right now
    def best_contacted_by(desperation = 0) 
      contact_by_hash = Hash.new(0)

      if self.can_email?
        contact_by_hash[:email] = (self.contact_by_email_pref * self.contact_by_email_score).round
      end

      # In normal business hours (more ways of contact are acceptable)
      if desperation >= 1 and Time.now.in_time_zone(self.time_zone_or_default).hour >= self.no_notifications_before and
        Time.now.in_time_zone(self.time_zone_or_default).hour < self.no_notifications_after

        if self.can_sms?
          contact_by_hash[:sms] = self.contact_by_sms_pref * self.contact_by_sms_score
          if desperation >= 4
            # disabled for now :)
            # contact_by_hash[:robocall] = (self.contact_by_robocall_pref * self.contact_by_robocall_score).round
          end
        end
        if self.twitter_username.present?
          if desperation >= 2
            contact_by_hash[:dm_tweet] = (self.contact_by_dm_tweet_pref * self.contact_by_dm_tweet_score).round          
          elsif desperation >= 3
            contact_by_hash[:public_tweet] = self.contact_by_public_tweet_pref * self.contact_by_public_tweet_score        
          end
        end
      end
      return contact_by_hash
    end
    
    def streak_to_desperation
      self.update_streak(visiting_now = false)
      if self.visit_streak > 2
        return 0
      elsif self.visit_streak > -7
        return 1
      elsif self.visit_streak > -14
        return 2
      elsif self.visit_streak > -30
        return 3
      else
        return 4
      end
    end
    
    # Select one way to contact this person
    def pick_a_contact_method(desperation = 0)
      contact_by_hash = self.best_contacted_by(desperation)
      weighted_contacts = Array.new
      contact_by_hash.each do |contact_type, weight|
        1.upto(weight).each do |num|
          weighted_contacts << contact_type
        end
      end
      if weighted_contacts.blank?
        return :sms
      else
        return weighted_contacts[rand(weighted_contacts.size)]
      end
    end
    
    # Fallback in case we try to contact them in a way that we can't.
    BACKUP_VIA = {:public_tweet => :not_contacted, 
                  :dm_tweet => :public_tweet, 
                  :email => :dm_tweet,
                  :sms => :email}
    
    def contact_them(via, message_name, data = nil)
      # Don't contact them if they've turned off this preference.
      return true unless self.get_notifications?
      
      if (via == :sms and !self.can_sms?) or (via == :email and !self.can_email?) or (via == :dm_tweet and !self.can_dm_tweet?) 
        return self.contact_them(BACKUP_VIA[via], message_name, data)
      elsif (via == :public_tweet and !self.can_public_tweet?)
        return true
      end
    
      self.update_streak(visiting_now = false)

      p "Contacting via #{via}: #{message_name}"
      message_data = {:data => data}

      # Create a notification object
      notification = Notification.new({
                      :user_id => self.id,
                      :delivered_via => via,
                      :message_style_token => 'generic',
                      :message_data => {:data => data},
                      :for_object => message_name})

      case message_name
        when :welcome_to_program
          # data is a program
          message_data[:data_model] = :program
          message_data[:subject] = "The #{data.name} program is all yours!"
          message_data[:pre_message] = "You've just bought the #{data.name} program. Congratulations!"
          if data.welcome_message.present?
            message_data[:message] = data.welcome_message
          else
            message_data[:message] = "You can now play #{data.name}.  To start, just hit the play button!"          
          end
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Start playing!"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}          

        when :new_coachee
          # data is a program_player
          message_data[:data_model] = :program_player
          user = data.user
          program_coach = data.program_coach
          message_data[:subject] = "Hello coach! You have a new coachee on the #{data.program.name} program!"
          message_data[:message] = "Their name is #{data.user.name}. Don't let them down! :)"          
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Start coaching!"
          notification.attributes = {:from_user_id => program_coach.user_id,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => false}          

        when :welcome_to_program_coach
          # data is a program_player
          message_data[:data_model] = :program_player
          user = data.user
          program_coach = data.program_coach
          message_data[:subject] = "Congrats! You have your very own coach for the #{data.program.name} program!"
          message_data[:pre_message] = "Message from your new coach, #{program_coach.user.name}:"
          if program_coach.present? and program_coach.message.present? 
            message_data[:message] = program_coach.message
          else
            message_data[:message] = "Hello! My name is #{program_coach.user.name}, and I will be here to help you in any way that I can.  To send me a message, just hit the \"Ask your coach\" button once you start playing."          
          end
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Start playing!"
          notification.attributes = {:from_user_id => program_coach.user_id,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}          

        when :welcome_to_program_play
          # data is a program
          message_data[:data_model] = :program
          message_data[:subject] = "The #{data.name} program has started!"
          message_data[:render_partial] = 'store/resources_for_email'
          
          if data.introduction_message.present?
            message_data[:message] = data.introduction_message
          else
            message_data[:message] = "You're all ready to go! Starting tomorrow, you will start getting messages from this program.  Good luck!"          
          end
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Start playing!"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}          
          
        when :daily_nudge
          # data is a hash with a message
          message_data[:data_model] = :message
          message_data[:subject] = data[:message]
          message_data[:render_partial] = 'mailer/daily_nudge'
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Play Budge!"
          message_data[:to_oauth] = self.oauth_for_site_token('twitter')
          message_data[:from_oauth] = OauthToken.budge_token
          message_data[:suppress_notification_url] = true
          
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => message_data[:data][:program_player_id],
                                     :delivered_immediately => true,
                                     :expected_response => true,
                                     :message_style_token => message_data[:data][:token]}

        when :moment_of_truth
          # data is a hash with a message
          message_data[:data_model] = :player_budge
          message_data[:subject] = "#{data.program_player.user.first_name}, your move on #{data.program_player.program.name}"
          message_data[:message] = "We haven't seen you in a couple days, so we're gonna tone down the reminders for #{data.program_player.program.name} until you tell us what to do."
          message_data[:render_partial] = "mailer/moment_of_truth"
          message_data[:to_user_name] = self.name
          message_data[:to_oauth] = self.oauth_for_site_token('twitter')
          message_data[:from_oauth] = OauthToken.budge_token
          message_data[:suppress_notification_url] = true
          message_data[:notification_url_text] = ""
          #message_data[:bcc] = 'busterbenson@gmail.com'
          
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.program_player.program_id,
                                     :delivered_immediately => true,
                                     :expected_response => true}
        
        when :since_u_been_gone
          # data is a hash with message_hash by status
          message_data[:data_model] = :message_hash
          message_data[:subject] = "New stuff on Budge since #{self.visit_streak.abs} days ago"
          message_data[:message] = "Whenever you're feeling ready for a new challenge, you can hop right back in where you left off."
          message_data[:render_partial] = 'mailer/since_u_been_gone'
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Get re-started!"
          message_data[:suppress_notification_url] = false
          message_data[:bcc] = 'busterbenson@gmail.com'
          
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => nil,
                                     :delivered_immediately => true,
                                     :expected_response => true}

        when :good_morning
          # data is a hash with message_hash by status
          message_data[:data_model] = :program_players_hash
          message_data[:subject] = "Good morning, #{self.first_name}!"
          message_data[:message] = "Say hello to your neighbors. These are people slightly ahead of you or slightly behind you in the programs you're playing."
          message_data[:render_partial] = 'mailer/good_morning'
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Start your day"
          message_data[:suppress_notification_url] = false
          # message_data[:bcc] = 'busterbenson@gmail.com'
          
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => nil,
                                     :delivered_immediately => true,
                                     :expected_response => true}
        

        when :nag
          # data is the number of things they have to do
          message_data[:data_model] = :integer
          if data == 1
            message_data[:subject] = "#{self.first_name} - you still have 1 thing to do for Budge today. Get on it!"
          else
            message_data[:subject] = "#{self.first_name} - you still have #{data} things to do for Budge today. Get on it!"          
          end
          message_data[:message] = "You are playing Budge in 'nag mode'. So go get your stuff done, then!"
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Play Budge!"
          message_data[:to_oauth] = self.oauth_for_site_token('twitter')
          message_data[:from_oauth] = OauthToken.budge_token
          
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => nil,
                                     :delivered_immediately => true,
                                     :expected_response => true}
        when :nag_prompt
          # data is the number of things they have to do
          message_data[:data_model] = :nag_mode_prompt
          user_nag_mode = self.user_nag_mode
          
          if via == :email
            message_data[:subject] = data.parsed_message({:user => self, :user_nag_mode => user_nag_mode})
            message_data[:message] = "You are playing #{user_nag_mode.present? ? user_nag_mode.program.name : 'Budge'} in 'Nag Mode'."
          else
            message_data[:subject] = data.parsed_message({:user => self, :user_nag_mode => user_nag_mode})
          end

          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Get to it!"
          message_data[:to_oauth] = self.oauth_for_site_token('twitter')
          message_data[:from_oauth] = OauthToken.budge_token
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => nil,
                                     :delivered_immediately => true,
                                     :expected_response => true}

        when :robocall_nag_followup
          # data is the number of things they have to do
          message_data[:data_model] = :nag_mode_prompt
          user_nag_mode = self.user_nag_mode
          
          message_data[:subject] = "Just following-up on my recent call. Here's a link for you to click!"
          if via == :email
            message_data[:message] = "You are playing #{user_nag_mode.present? ? user_nag_mode.program.name : 'Budge'} in 'Nag Mode'."
          end

          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Get on it!"
          message_data[:to_oauth] = self.oauth_for_site_token('twitter')
          message_data[:from_oauth] = OauthToken.budge_token
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => nil,
                                     :delivered_immediately => true,
                                     :expected_response => true}
        
        
        when :player_message
          # data is player_message
          message_data[:data_model] = :player_message
          # Get set up
          @program_player = data.program_player
          @to_user = @program_player.user

          @to_oauth = @program_player.user.oauth_for_site_token('twitter')

          # Convert this message into something that will work via all delivery methods
          message_data[:subject] = data.message_subject(via)
          message_data[:pre_message] = data.pre_message(via)
          message_data[:message] = data.message_body(via)
          message_data[:to_user_name] = @to_user.name

          message_data[:to_oauth] = @to_oauth
          message_data[:to_oauth_username] = @to_oauth.remote_username rescue nil
          message_data[:from_oauth] = OauthToken.budge_token('twitter')
          message_data[:from_oauth_username] = message_data[:from_oauth].remote_username 

          # Not all player messages need to link back to the program
          if via == :email or (data.auto_message.present? and data.auto_message.include_link?)
            message_data[:notification_url_text] = "Get on it!"
            notification.attributes = {:from_user_id => nil,
                                       :from_system => true,
                                       :for_id => data.id,
                                       :delivered_immediately => true,
                                       :expected_response => data.content.match(/#{DOMAIN}/).present?}

          # Suppress the creation of the notification for messages that don't need to link back
          else
            message_data[:suppress_notification] = true
          end          
          
        when :super_follow_checkin  
          # data is the player_message object
          message_data[:data_model] = :entry

          if via == :email
            message_data[:subject] = "#{data.user.name}: #{data.message}"
            message_data[:pre_message] = "#{data.from_user.name} just checked in:"
            message_data[:message] = data.content       
          else
            # Make it SMS appropriate...
            content = "#{data.user.name}: #{data.message}"
            content = "#{content[0..117]}..." if content.size > 120
            message_data[:subject] = content         
          end
          
          message_data[:to_user_name] = self.name

          message_data[:notification_url_text] = "Read and reply"
          notification.attributes = {:from_user_id => data.user.id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}        
          
        # From the batphone
        when :message_to_coach
          # data is the player_message object
          message_data[:data_model] = :player_message

          if via == :email
            message_data[:subject] = "#{data.from_user.name} needs you! (in #{data.program.name})"            
            message_data[:pre_message] = "#{data.from_user.name} says:"
            message_data[:message] = data.content       
          else
            # Make it SMS appropriate...
            content = "#{data.from_user.name}: #{data.content}"
            content = "#{content[0..117]}..." if content.size > 120
            message_data[:subject] = content         
          end
          
          message_data[:to_user_name] = data.to_user.name

          message_data[:notification_url_text] = "Read and reply"
          notification.attributes = {:from_user_id => data.from_user.id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}                

        # From the batphone
        when :message_to_player
          # data is the player_message object
          message_data[:data_model] = :player_message

          if via == :email
            message_data[:subject] = "Your coach for #{data.program.name} has sent you a message!"            
            message_data[:message] = data.content       
          else
            # Make it SMS appropriate...
            content = "#{data.from_user.name}: #{data.content}"
            content = "#{content[0..117]}..." if content.size > 120
            message_data[:subject] = content         
          end

          message_data[:to_user_name] = data.to_user.name
          message_data[:to_oauth_username] = data.to_user.oauth_for_site_token('twitter')
          message_data[:from_oauth] = data.from_user.oauth_for_site_token('twitter')

          message_data[:notification_url_text] = "Read and reply"
          notification.attributes = {:from_user_id => data.from_user.id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}                

        # Comment to an entry
        when :entry_comment
          # data is the entry_comment object
          message_data[:data_model] = :entry_comment

          if via == :email
            if data.entry.program.present?
              message_data[:subject] = "#{data.user.name} has commented on your #{data.entry.program.name} program"          
            else
              message_data[:subject] = "#{data.user.name} has commented on your Budge checkin"                           
            end     
            message_data[:message] = message_data[:subject]+ "\n" + data.message
          else
            # Make it SMS appropriate...
            content = "#{data.user.name}: #{data.message}"
            message_data[:subject] = content         
          end
          
          message_data[:to_user_name] = self.name

          message_data[:notification_url_text] = "Reply?"
          notification.attributes = {:from_user_id => data.entry.user.id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}                

        # Comment to an entry
        when :entry_comment_participant
          # data is the entry_comment object
          message_data[:data_model] = :entry_comment

          if via == :email
            message_data[:subject] = "#{data.user.name} made a comment on something you commented on"            
            message_data[:message] = message_data[:subject]+"\n" + data.message       
          else
            # Make it SMS appropriate...
            content = "#{data.user.name}: #{data.message}"
            message_data[:subject] = content         
          end
          
          message_data[:to_user_name] = self.name

          message_data[:notification_url_text] = "Reply?"
          notification.attributes = {:from_user_id => data.entry.user.id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}                

        # An auto-checkin completed their level and now they need to choose a new level
        when :completed_level
          # data is the player_budge object that was just completed
          message_data[:data_model] = :player_budge

          message_data[:subject] = "You just completed #{data.program_budge.budge_level} of #{data.program_budge.program.name}!"            
          message_data[:message] = "Congratulations! Which level of #{data.program_budge.program.name} would you like to play next?"       

          message_data[:notification_url_text] = "Choose next level"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}  

        when :coached_player_checked_in
          # data is the entry object that was just checked in to
          message_data[:data_model] = :entry

          message_data[:subject] = data.summary_from_metadata
          message_data[:message] = "Check in with them and see if you can offer them any help or encouragement, why don'tcha!"                 

          message_data[:notification_url_text] = "Coach them!"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}  

        when :coach_batch_report
          # data is a user (who needs to be a coach)
          message_data[:data_model] = :user
          message_data[:subject] = "Budge Coach daily report!"
          message_data[:render_partial] = 'coach/coach_report_for_email'
          
          message_data[:message] = "Coach the bejeezus out of these people! <a href='http://#{DOMAIN}/coach'>Go, coach, go</a>!"          
          message_data[:to_user_name] = self.name
          message_data[:notification_url_text] = "Go, coach, go!"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => false}          
  
        when :auto_checkin_received
          # data is the checkin
          message_data[:data_model] = :checkin
          exclamations = ['Got it!', 'Sweet!', 'Bam!', 'Whoop!', 'Tada!', 'Wa-pow!']
          message_data[:subject] = exclamations[rand(exclamations.size)]
          message_data[:subject] += " You #{data.statement(:past)}"

          summary_results = data.summary_results
          if data.trait.cumulative_results?
            message_data[:subject] += " (30 day count is #{summary_results[:total]})"
          else 
            difference = ((data.amount_decimal - summary_results[:average])*100).to_i/100.0
            direction = (difference > 0) ? "up" : "down"
            message_data[:subject] += " (#{direction} #{difference.abs} #{data.user.weight_pref} from avg)" 
            if summary_results[:num_results].present? and summary_results[:num_results] > 0
              message_data[:subject] += " http://bud.ge/chart"
            end         
          end

          message_data[:message] = "#{message_data[:subject]}\n\nThe snail serves to please. Have a nice day!"
          message_data[:suppress_notification] = true
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => false}
        when :invite_to_support
          # data is the supporter
          message_data[:data_model] = :supporter
          message_data[:deliver_to_non_beta] = true
          message_data[:subject] = "I starting the the #{data.program.name} program on Budge, and I could use your encouragement. Want to be my coach?"
          message_data[:message] = "#{data.program_player.user.name} needs your help! Support a friend?"
          message_data[:from_oauth] = data.program_player.user.oauth_for_site_token('twitter')
          message_data[:to_oauth_username] = data.user_twitter_username
          message_data[:to_user_name] = data.user_name
          notification.attributes = {:from_user_id => data.program_player.user_id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}

        when :invitation_to_program_success
          # data is an invitation
          message_data[:data_model] = :invitation
          message_data[:subject] = "#{data.invited_user.name} accepted your invitation to Budge"
          message_data[:message] = "#{data.invited_user.name} is rocking Budge, thanks to you."
          num_invites = data.program_player.num_invites_available
          if num_invites <= 1
            message_data[:message] = "Feels good, don't it?"                    
          elsif num_invites == 1
            message_data[:message] = "Heck yeah! You have 1 more invite to give out."            
          else
            message_data[:message] = "Hooray! Keep at it! You have #{num_invites} more invites to give out."                      
          end
          message_data[:to_user_name] = data.user.name
          message_data[:notification_url_text] = "Share the love!"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => false}                  

        when :rewarded_invites
          # data is a program_player
          last_completed_budge = data.last_completed_budge
          level_number = (last_completed_budge.present? and last_completed_budge.program_budge.present?) ? last_completed_budge.program_budge.budge_level : "a level"
          message_data[:data_model] = :program_player
          message_data[:subject] = "You've completed #{level_number} in #{data.program.name}! Want to share the love?"
          message_data[:message] = "Awesome! You just completed #{level_number} of #{data.program.name}, and are making great progress! Because of your amazing talent and skill, you've earned the ability to invite <strong>#{data.num_invites_available} #{data.num_invites_available == 1 ? 'person' : 'people'}</strong> to play it with you! Do you know anyone that might appreciate it like you do?"
          message_data[:to_user_name] = data.user.name
          message_data[:notification_url_text] = "Invite your friends and family!"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => false}                  

        when :new_follower
          # data is a relationship (this is being sent to the followed_user)
          message_data[:data_model] = :relationship
          message_data[:subject] = "Psst. You've got a fan on Budge: #{data.user.name}"
          message_data[:message] = "#{data.user.name} thinks you're nifty."
          message_data[:to_user_name] = data.followed_user.name
          message_data[:notification_url_text] = "Holler back?"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => false}                  
          
        when :completed_program_congrats
          # data is a program_player that has been marked complete
          # Still in progress

        # Inviting people in the waiting room
        when :invite_to_beta_cohort
          # data is the cohort tag (stored in notification.message_style_token)
          message_data[:data_model] = :string

          message_data[:subject] = "You made it! You have been granted access to Bud.ge. Get healthy, or whatever:"       

          message_data[:to_oauth_username] = self.twitter_username
          message_data[:to_user_name] = self.name
          message_data[:from_oauth] = OauthToken.budge_token('twitter')

          message_data[:notification_url_text] = "Check out Budge!"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => nil,
                                     :delivered_immediately => true,
                                     :expected_response => true,
                                     :message_style_token => data}                

        when :phone_number_invalid
          # data is the phone number that didn't work
          message_data[:data_model] = :phone_number
          message_data[:subject] = "Oops, your phone number didn't work"
          message_data[:message] = "At the moment, we can only send SMS to phone numbers in the US and Canada.  If you are in one of those places, verify that this number looks right to you (#{data}) and try re-entering it in your settings page."
          message_data[:notification_url_text] = "Edit your phone number"
          notification.attributes = {:from_user_id => nil,
                                     :from_system => true,
                                     :for_id => nil,
                                     :delivered_immediately => true,
                                     :expected_response => false,
                                     :message_style_token => data}   
        
        when :liked_entry
          # data is the entry_comment object
          message_data[:data_model] = :like

          message_data[:subject] = "#{data.user.name} liked your post <3"          
          message_data[:message] = message_data[:subject]          
          message_data[:to_user_name] = self.name

          message_data[:notification_url_text] = "Check it out"
          notification.attributes = {:from_user_id => data.user.id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}                
                     
          
      end
      
      # Attach a notification URL to the end of this message
      unless message_data[:suppress_notification]
        notification.save
  
        message_data[:notification] = notification
        message_data[:notification_url] = notification.url
  
        # Decrement the score by 1, and increment again if they respond
        if notification.expected_response?
          case via
            when :email
              if self.contact_by_email_score > 1
                self.update_attributes({:contact_by_email_score => self.contact_by_email_score-0.1})
              end
            when :sms
              if self.contact_by_sms_score > 1
                self.update_attributes({:contact_by_sms_score => self.contact_by_sms_score-0.1})
              end
            when :public_tweet
              if self.contact_by_public_tweet_score > 1
                self.update_attributes({:contact_by_public_tweet_score => self.contact_by_public_tweet_score-0.1})
              end
            when :dm_tweet
              if self.contact_by_dm_tweet_score > 1
                self.update_attributes({:contact_by_dm_tweet_score => self.contact_by_dm_tweet_score-0.1})
              end
            when :robocall
              if self.contact_by_robocall_score > 1
                self.update_attributes({:contact_by_robocall_score => self.contact_by_robocall_score-0.1})
              end
            when :facebook_wall
              if self.contact_by_facebook_wall_score > 1
                self.update_attributes({:contact_by_facebook_wall_score => self.contact_by_facebook_wall_score-0.1})
              end
          end
        end
      end

      Notification.deliver_message(via, message_data, self, message_data[:notification])
    end

    def self.non_user_contact(via, message_name, data)
      message_data = {:data => data}

      # Create a notification object
      notification = Notification.new({
                      :user_id => nil,
                      :delivered_via => via,
                      :message_style_token => 'generic',
                      :message_data => {:data => data},
                      :for_object => message_name})
      sender = nil

      case message_name
        when :invite_to_support
          # data is the supporter
          message_data[:data_model] = :supporter
          message_data[:deliver_to_non_beta] = true
          message_data[:from_oauth] = data.program_player.user.oauth_for_site_token('twitter')
          message_data[:to_oauth_username] = data.user_twitter_username
          message_data[:to_user_name] = data.user_name
          message_data[:subject] = "I starting the the #{data.program.name} program on Budge, and I could use your encouragement. Want to be my coach?"
          message_data[:message] = "#{data.program_player.user.name} needs your help! Support a friend?"
          notification.attributes = {:from_user_id => data.program_player.user_id,
                                     :from_system => false,
                                     :for_id => data.id,
                                     :delivered_immediately => true,
                                     :expected_response => true}                                     
      end

      # Attach a notification URL to the end of this message
      unless message_data[:suppress_notification]
        notification.save
        message_data[:notification] = notification
        message_data[:notification_url] = notification.url
      end
      
      # Send!  Requires:
      # message_data[:to_user_name] for everything
      # message_data[:to_email] to send email
      # message_data[:to_phone] to send sms
      # message_data[:from_oauth] to send tweet or dm
      # message_data[:to_oauth] or message_data[:to_oauth_username] to send tweet or dm
      Notification.deliver_message(via, message_data, nil, message_data[:notification])
    end
    
    def get_streak
      self.update_streak
      return self.visit_streak
    end
    
    def update_streak(visiting_now = false)
      # Scope the time zone
      current_time_zone = Time.zone
      Time.zone = self.time_zone_or_default

      if !self.last_logged_in
        if visiting_now
          self.update_attributes({:last_logged_in => Time.zone.now, :visit_streak => 1, :next_nudge_at => nil})
        end
      else
        days_since_last_visit = Time.zone.now.to_date - self.last_logged_in.in_time_zone(self.time_zone_or_default).to_date
        negative_streak = self.last_logged_in.in_time_zone(self.time_zone_or_default).to_date - Time.zone.now.to_date
  
        # If they are visiting right now...      
        if visiting_now
          time_zone_now = Time.zone.now
        
          # If it has been more than 0 days since their last visit
          if days_since_last_visit > 0
          
            # At the very least, reset them to 1 now
            if self.visit_streak < 1 or days_since_last_visit > 1
              self.update_attributes({:visit_streak => 1, 
                                      :last_logged_in => time_zone_now,
                                      :next_nudge_at => nil})
            
            # If it has been exactly 1 day since their last visit, increment by 1
            elsif days_since_last_visit == 1
              self.update_attributes({:visit_streak => self.visit_streak+1, 
                                      :last_logged_in => time_zone_now,
                                      :next_nudge_at => nil})
              
            else
              self.update_attributes({:last_logged_in => time_zone_now,
                                      :next_nudge_at => nil})
            end
                                  
          # If it's 0 (can't be < 0), ignore it since they already visited today
          else
            self.update_attributes({:last_logged_in => time_zone_now,
                                    :next_nudge_at => nil})
          end
          
        # If they aren't logged in right now
        elsif self.visit_streak != negative_streak and negative_streak < -1
          self.update_attributes({:visit_streak => negative_streak})
        end
      end
      Time.zone = current_time_zone
    end
    
    def self.pick_next_nudge_times_for_lazy_players
      global_weights = Notification.get_global_weights 
      User.where('last_logged_in < ? and next_nudge_at is null', Time.now.utc-4.days).select(:id).each_slice(1000) do |user_ids|
        user_ids.each do |user_id|
          user = User.find user_id
          next unless user.in_beta?
          user.update_next_nudge(global_weights)
        end
      end
    end

    NUDGES = {:needs_onboarding => [
                {:message => "Let's get you started in #PROGRAM#!",
                 :token => "onboarding_basic",
                 :substitute_program => true}
                ],
              :needs_to_choose_another_budge => [
                {:message => "I scheduled you to play #PROGRAM# (#BUDGE#)! Are you in?",
                 :token => "choose_new_budge_basic",
                 :substitute_program => true,
                 :substitute_budge => true}
                ],
              :time_up => [
                {:message => "I re-scheduled you to play #PROGRAM# (#BUDGE#) starting #STARTDATE#! Are you in?",
                 :token => "time_up_reschedule",
                 :substitute_program => true,
                 :substitute_budge => true,
                 :substitute_start_date => true},
                {:message => "I re-scheduled you to play #PROGRAM# (#BUDGE#) starting #STARTDATE#! Accept or reject?",
                 :token => "time_up_reschedule_2",
                 :substitute_program => true,
                 :substitute_budge => true,
                 :substitute_start_date => true},
                {:message => "I scheduled you to play #PROGRAM# (#BUDGE#)! Are you in?",
                 :token => "time_up_schedule",
                 :substitute_program => true,
                 :substitute_budge => true},
                {:message => "I scheduled you to play #PROGRAM# (#BUDGE#)! Accept or reject?",
                 :token => "time_up_schedule",
                 :substitute_program => true,
                 :substitute_budge => true}
                ],
              :scheduled => [
                {:message => "#PROGRAM# is scheduled to start soon. Are you ready?",
                 :token => "scheduled_basic",
                 :substitute_program => true}
                ],
              :caught_up => [],
              :playing => [
                {:message => "The universe has aligned for you to play #PROGRAM#.",
                 :token => "playing_universe",
                 :substitute_program => true},
                {:message => "Knock knock. Who's there? #PROGRAM#, that's who. Can you come play?",
                 :token => "playing_knock",
                 :substitute_program => true},
                {:message => "You should play #PROGRAM# today. The time is ripe like a mango!",
                 :token => "playing_ripe",
                 :substitute_program => true},
                {:message => "You're on Day #DAYNUM# of #PROGRAM# (#BUDGE#). Can you play right now?",
                 :token => "playing_day_number",
                 :substitute_program => true,
                 :substitute_budge => true,
                 :substitute_day_number => true},
                {:message => "If you don't play #PROGRAM# today, the Budge snail might get angry!",
                 :token => "playing_angry",
                 :substitute_program => true,
                 :substitute_budge => true,
                 :substitute_day_number => true}
                ]}
                
    def self.test_since_u_been_gone
      global_weights = Notification.get_global_weights 
      
      programs = Program.where(:featured => true)
      program_victories = Entry.where(:message_type => 'declare_end',
                                      :privacy_setting => Entry::PRIVACY_PUBLIC).
                                order('id DESC').
                                limit(20).
                                select{|e|e.metadata.present? and 
                                          e.metadata[:declaration] == :victory and 
                                          e.metadata[:answers][:answer_1].present?}
      time_now = Time.now.utc
      User.find(1).send_nudge_to_lazy_player(global_weights, programs, program_victories)
    end
    
    def self.send_nudge_to_lazy_players
      global_weights = Notification.get_global_weights 
      
      programs = Program.where(:featured => true)
      program_victories = Entry.where(:message_type => 'declare_end',
                                      :privacy_setting => Entry::PRIVACY_PUBLIC).
                                order('id DESC').
                                limit(20).
                                select{|e|e.metadata.present? and 
                                          e.metadata[:declaration] == :victory and 
                                          e.metadata[:answers][:answer_1].present?}
      time_now = Time.now.utc
      User.where('next_nudge_at < ? AND in_beta = ?', time_now+1.hour, true).each do |user|
        if user.next_nudge_at > time_now
          # prep them for a message next hour
          user.delay.autofollow_people_on_other_networks        
        else
          user.send_nudge_to_lazy_player(global_weights, programs, program_victories)
        end
      end
    end
    
    
    def send_nudge_to_lazy_player(global_weights = nil, programs = Program.where(:featured => true), program_victories = [])
      # Only send it if we can email
      if self.can_email?
        via = :email
      else
        self.update_attributes(:next_nudge_at => nil)
        self.update_next_nudge(global_weights)      
        return false
      end

      global_weights ||= Notification.get_global_weights
      # Find active programs
      program_players = self.program_players.where('program_id is not null').order('updated_at desc')
      return "No programs" unless program_players.present?
      program_players.delete_if{|p|p.program.blank? || !p.program.featured?}
      return "No programs" unless program_players.present?      
      
      # Make sure they're really lazy
      self.update_streak(false)
      return "Not lazy" if self.visit_streak >= -3 and Rails.env.production?

      # :victorious
      # :defeated
      # :needs_to_choose_another_budge
      # :needs_contact_info    
      # :time_up
      # :needs_reviving
      # :ready_to_start
      # :scheduled
      # :caught_up
      # :playing
      message_hash = {:program_players => Hash.new, 
                      :program_victories => program_victories[0..3], 
                      :last_visited_days_ago => self.visit_streak.abs,
                      :num_programs_in_progress => 0}

      # Potential statuses for each program
      max_program_id = 0
      program_players.each do |program_player|
        status = program_player.program_status
        next if status == :victorious or status == :defeated or status == :scheduled
        
        message_hash[:num_programs_in_progress] += 1
        message_hash[:program_players] ||= Array.new
        message_hash[:program_players] << program_player        
        max_program_id = program_player.program_id if program_player.program_id > max_program_id
      end

      message_hash[:new_programs] = programs.select{|p|p.id > max_program_id}
      message_hash[:new_friends] = Relationship.where(:user_id => self.id).where('created_at > ?', self.last_logged_in-30.days).order('created_at DESC').map{|r|r.followed_user}

      # Contact them if we have something to share
      if message_hash[:program_players].present? or message_hash[:program_victories].present? or message_hash[:new_programs].present? or message_hash[:new_friends].present?
        self.contact_them(via, :since_u_been_gone, message_hash)
      end
      
      self.update_attributes(:next_nudge_at => nil)
      self.update_next_nudge(global_weights)      
      return true
    end
    
    def nag_mode_is_on?
      self.user_nag_mode.present?
    end
    
    def user_nag_mode
      date = Time.now.in_time_zone(self.time_zone_or_default).to_date
      user_nag_mode = UserNagMode.where(['user_id = ? AND start_date <= ? AND end_date > ? AND active = ?',
                                         self.id, date, date, true]).first    
    end
    
    # Figure out when we should budge them next
    def update_next_nudge(global_weights = nil)
      self.update_streak(false)
      next_nudge = self.pick_next_nudge_time(1)
      self.update_attributes({:next_nudge_at => next_nudge}) if next_nudge.present?
      return true
    end

    def pick_next_nudge_time(limit = 1)
      # Range to notify between
      min_datetime = Time.now.in_time_zone(self.time_zone_or_default)+3.hours
      max_datetime = nil

      # Use global weights if we don't have much user data
      if self.visit_stats_sample_size < 50
        optimize_by = :global_day_and_hour
        weights = Notification.get_global_weights 
  
      # Use general hourly data unless we have a fairly good sized chunck of user data
      elsif self.visit_stats_sample_size < 500
        optimize_by = :user_hour
        weights = Notification.get_user_weights(self, optimize_by.to_s)

      # Use day_and_hour data if we have a lot of user data
      else
        optimize_by = :user_day_and_hour
        weights = Notification.get_user_weights(self, optimize_by.to_s)

      end

      # Visited within last 2 weeks
      if self.visit_streak > -15
        min_datetime = min_datetime+1.day
        max_datetime = min_datetime+3.days

      # Visited between 15 and 30 days ago (in a week or so)
      elsif self.visit_streak > -30
        min_datetime = min_datetime+3.days
        max_datetime = min_datetime+5.days
    
      # 1-4 months dormant (every week or two)
      elsif self.visit_streak > -120
        min_datetime = min_datetime+7.days
        max_datetime = min_datetime+7.days
      
      # Over 2 months dormant (once a month)
      else
        min_datetime = min_datetime+28.days
        max_datetime = min_datetime+7.days

      end
      
      by_the_hour = min_datetime
      ranked_hours = Hash.new
      while by_the_hour < max_datetime
        if weights[:day_and_hour].present?
          if weights[:day_and_hour][by_the_hour.wday].present? and weights[:day_and_hour][by_the_hour.wday][by_the_hour.hour].present?
            ranked_hours[by_the_hour] = weights[:day_and_hour][by_the_hour.wday][by_the_hour.hour]
          elsif weights[:hour][by_the_hour.hour].present?
            ranked_hours[by_the_hour] = weights[:hour][by_the_hour.hour]   
          end
        elsif weights[:hour].present?
            ranked_hours[by_the_hour] = weights[:hour][by_the_hour.hour]   
          
        else
            ranked_hours[by_the_hour] = 0
        end
        by_the_hour += 1.hour
      end
      
      # Get the top 5 options
      top_ranked = ranked_hours.sort_by{|date,weight|weight}.reverse.to_a[0..4]      

      # Randomly pick
      if limit == 1
        next_notification = top_ranked[rand(top_ranked.size)][0]
        return next_notification    
      elsif limit > 1
        pick_random = 0
        next_notifications = []
        while pick_random < limit
          next_notifications << top_ranked[pick_random]
          pick_random += 1
        end
        return next_notifications          
      end
    end

    def self.send_good_morning_email
      time_now = Time.now.utc
      User.where('last_logged_in >= ? AND wake_hour_utc = ? AND in_beta = ?', time_now-3.days, time_now.hour, true).each do |user|
        user.send_good_morning_email
      end
    end
    
    def send_good_morning_email
      valid_program_players = self.valid_program_players
      program_players_and_neighbors = []
      valid_program_players.each do |program_player|
        program_status = program_player.program_status
        next if program_status == :victorious or program_status == :defeated or program_status == :scheduled
        leader_neighbors = program_player.leader_neighbors
        program_players_and_neighbors << {:program_player => program_player,
                                          :up2 => leader_neighbors[:up2],
                                          :up1 => leader_neighbors[:up1],
                                          :down => leader_neighbors[:down],
                                          :you => leader_neighbors[:you]}
                                         
      end
      
      if program_players_and_neighbors.present?
        self.contact_them(:email, :good_morning, program_players_and_neighbors)
      end
      return program_players_and_neighbors
    end
        
    def him_or_her
      return 'them' unless self.gender.present?
      case self.gender
        when 'male'
          return 'him'
        when 'female'
          return 'her'
        else
          return 'them'
      end
    end

    def his_or_her
      return 'their' unless self.gender.present?
      case self.gender
        when 'male'
          return 'his'
        when 'female'
          return 'her'
        else
          return 'their'
      end
    end

    def he_or_she
      return 'they' unless self.gender.present?
      case self.gender
        when 'male'
          return 'he'
        when 'female'
          return 'she'
        else
          return 'they'
      end
    end

    def he_or_she_possessive
      return "they're" unless self.gender.present?
      case self.gender
        when 'male'
          return "he's"
        when 'female'
          return "she's"
        else
          return "they're"
      end
    end
    
    def photo_url(size = :small)
      if self.photo?
        return self.photo(size)
      else
        width = 75
        case size
          when :large
            width = 800
          when :medium 
            width = 300
          when :small
            width = 75
          when :tiny
            width = 30
        end
        digest = Digest::MD5.hexdigest(self.email.downcase) rescue nil
        if !digest.blank?
          tag = "http://www.gravatar.com/avatar/#{digest}?s=#{width}&d="+
                 "http://#{DOMAIN}/images/missing.jpg"
          return tag
        else
          return "http://#{DOMAIN}/images/missing.jpg"            
        end
      end
    end
    
    # Figure out what their best streak level is.
    def streak_level_up
    end
    
    def level_up(new_level = nil, via_checkin = nil)
      return
    end
    
    def add_addons_for_level(level)
      Addon.find(:all, :conditions => ['visible_at_level <= ? AND auto_unlocked_at_level <= ?', level, level]).each do |addon|
        # Was getting errors doing just user_addons.exists?({:addon_id => addon.id})
        unless self.user_addons.to_a.select{|u|u.addon_id == addon.id}.present?
          self.user_addons.create({:addon_id => addon.id})
        end
      end
    end

    # Disabled for now
    def update_addon_cache
      return true
      self.user_addons.reload
      cache = {}
      cache = self.user_addons.select{|ua|ua.activated?}.each{|ua|cache[ua.addon.token] = true}
      self.update_attributes({:addon_cache => cache})
    end
    
    def unlocked(addon_token)
      if self.addon_cache.present? and addon_token.present?
        if self.addon_cache[addon_token.to_s].present?
          return true
        else
          return false
        end
      end
      return false
    end
    
    def give_level_up_credits(num_credits = 0)
      self.update_attributes({:level_up_credits => self.level_up_credits+num_credits,
                              :total_level_up_credits_earned => self.total_level_up_credits_earned+num_credits})
    end

    def spend_level_up_credits(num_credits = 0)
      self.update_attributes({:level_up_credits => self.level_up_credits-num_credits})
    end
        
    def available_budge_packs
      Pack.where(:launched => true, :public => true).order(:position)
    end

    def normalize_phone_number
      if phone.blank?
        self.phone_normalized = nil
      else
        self.phone_normalized = User.normalize_phone_number(self.phone)
      end
    end
    
    def self.normalize_phone_number(raw_number)
      return nil unless raw_number.present?
      normalized = raw_number.gsub(/\D/, "") 
      if normalized.size == 10
        normalized = "1#{normalized}"
      end
      return normalized
    end
    
    def self.send_phone_verification_texts
      User.where(:send_phone_verification => true).each do |user|
        if user.phone_normalized.present? #and !user.can_sms?
          begin
            code = TwilioApi.send_text(user.phone_normalized, "Hey, #{user.name}! To verify your phone number for Budge, reply with 'Y'.")  
            user.update_attributes(:send_phone_verification => false)
          rescue => e
            if user.can_email?
                user.contact_them(:email, :phone_number_invalid, user.phone)
            end
            user.update_attributes(:phone => "0",
                                   :phone_verified => nil,
                                   :phone_normalized => nil,
                                   :send_phone_verification => false)
          end
        end
      end
      return true
    end
    
    def set_wake_and_bed_utc_times
      old_time_zone = Time.zone
      Time.zone = self.time_zone_or_default
      
      midnight = Time.zone.now.midnight
      wake = midnight+self.no_notifications_before.hours
      bed = midnight+self.no_notifications_after.hours
      
      self.wake_hour_utc = wake.utc.hour
      self.bed_hour_utc = bed.utc.hour
      self.save
      
      Time.zone = old_time_zone
    end

    def autofollow_people_on_other_networks
      facebook_oauth = self.oauth_for_site_token('facebook')
      twitter_oauth = self.oauth_for_site_token('twitter')
      foursquare_oauth = self.oauth_for_site_token('foursquare')
      if facebook_oauth.present? and (facebook_oauth.friend_id_hash_updated.blank? or facebook_oauth.friend_id_hash_updated < Time.zone.now-7.days)
        new_facebook_friends = facebook_oauth.autofollow_friends
      end
      if twitter_oauth.present? and (twitter_oauth.friend_id_hash_updated.blank? or twitter_oauth.friend_id_hash_updated < Time.zone.now-7.days)
        new_twitter_friends = twitter_oauth.autofollow_friends
      end
      if foursquare_oauth.present? and (foursquare_oauth.friend_id_hash_updated.blank? or foursquare_oauth.friend_id_hash_updated < Time.zone.now-7.days)
        new_foursquare_friends = foursquare_oauth.autofollow_friends
      end 
        
      # If we found new friends, add a new item to their stream about it.
      new_relationships = self.relationships.where(:invisible => false, :read => false)
      p "new relationships: #{new_relationships.size}"
      if new_relationships.present?
        # Update the reverse relationships
        new_relationships.each do |relationship|
          if relationship.followed_user.blank?
            relationship.destroy
          else
            # Make this reciprocal and visible if they are foursquare or facebook friends (but not for twitter friends)
            relationship.followed_user.follow_user(self, read = false, invisible = ((relationship.facebook_friends? or relationship.foursquare_friends?) ? false : true), auto = true, notify = false)
          end
        end            
      end
    end
    
    def follow_user(friend, read = false, invisible = false, auto = false, notify = false)
      return unless friend.present?
      relationship = Relationship.find(:first, :conditions => ['user_id = ? AND followed_user_id = ?',
                                                               self.id, friend.id])
      if relationship.blank?
        relationship = Relationship.create({:user_id => self.id,
                             :followed_user_id => friend.id,
                             :read => read, 
                             :invisible => invisible,
                             :auto => auto})
      elsif relationship.present? and relationship.invisible != invisible
        relationship.update_attributes(:invisible => invisible)
      end
      if notify and !relationship.notified_followee?
        relationship.notify_followee
        relationship.update_attributes(:notified_followee => true)
      end
      return relationship
    end

    # pounds per kilogram 2.20462262                  
    # {"updatetime"=>1294287876,                      ## Time.at(epoch) 
    #  "measuregrps"=>[
    #                  {"measures"=>[
    #                                {"unit"=>-2,     ## power of 10 for value
    #                                 "type"=>4,      ## 1 = weight kg, 4 = height m, 5 = free fat mass kg, 6 fat ratio %, 8 fat mass kg, 9 sys bld prss, 10 dia bld prss, 11 heart rate
    #                                 "value"=>185}], ## value
    #  "category"=>1,                                 ## 1 = measure, 2 = target
    #  "attrib"=>2,                                   ## 0 = from device, unambiguous, 1 = from device, ambiguous, 2 = manual entry, 4 = manual entry during user creation
    #  "grpid"=>7577739, 
    #  "date"=>1294186071}
    

    def backfill_withings(startdate = 0, enddate = Time.now.utc.to_i, overwrite = false)

      # Track weight with this Trait
      weigh_trait = Trait.where(:verb => 'weigh in', :answer_type => ':pounds').first
      logger.warn "Trait: #{weigh_trait.id}"
      return unless weigh_trait.present?

      # And this UserTrait
      weigh_user_trait = UserTrait.find_or_create_by_trait_id_and_user_id(weigh_trait.id, self.id)
      logger.warn "UserTrait: #{weigh_user_trait.id}"
      return unless weigh_user_trait.present?
      
      uri = URI.parse("http://wbsapi.withings.net/measure")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      formdata = {:action => 'getmeas',
                 :userid => self.withings_user_id,
                 :publickey => self.withings_public_key,
                 :startdate => startdate,
                 :enddate => enddate}
                 
      request.set_form_data(formdata)
      response = http.request(request)
      parsed_json = JSON.parse(response.body)
      logger.warn parsed_json.inspect

      # If we have results, and they aren't blank
      if parsed_json['status'].to_i == 0 and !parsed_json['body'].blank?
        parsed_json['body']['measuregrps'].each do |measurement|            
          # {"unit"=>-3, "type"=>1, "value"=>79700} = weight kg 
          # Type	Description
          # 1	Weight (kg)
          # 4	Height (meter)
          # 5	Fat Free Mass (kg)
          # 6	Fat Ratio (%)
          # 8	Fat Mass Weight (kg)
          # 9	Diastolic Blood Pressure (mmHg)
          # 10	Systolic Blood Pressure (mmHg)
          # 11	Heart Pulse (bpm)
          
          next unless measurement['category'].to_i == 1 and measurement['attrib'].to_i <= 2
          measurement['measures'].each do |group|
        
            if group['type'].to_i == 1 # weight kg
              # convert to lbs unless they're using kgs
              withings_weight = (group['value'].to_f * (self.weight_pref == 'kgs' ? 1 : 2.20462262)) / (10**group['unit'].abs)

              weigh_user_trait.save_new_data({:user_id => self.id,
                                              :trait_id => weigh_trait.id,
                                              :user_trait_id => weigh_user_trait.id,
                                              :did_action => true,
                                              :is_player => true,
                                              :date => Time.at(measurement['date']).to_date,
                                              :checkin_datetime => Time.at(measurement['date']).in_time_zone(self.time_zone_or_default),
                                              :checkin_datetime_approximate => false,
                                              :amount_decimal => withings_weight,
                                              :checkin_via => 'withings',
                                              :comment => nil,
                                              :remote_id => nil},
                                             {})

            end
          end
        end
      end
    end
    
    def subscribe_withings
      uri = URI.parse("http://wbsapi.withings.net/notify")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({:action => 'subscribe',
                             :userid => self.withings_user_id,
                             :publickey => self.withings_public_key,
                             :callbackurl => "http://#{DOMAIN}/oauth/withings_update_remote/#{self.id}",
                             :comment => "Budge"})
      response = http.request(request)
      parsed_json = JSON.parse(response.body)

      if parsed_json['status'] == 0
        self.update_attributes({:withings_subscription_renew_by => Date.today+20.days})
        TrackedAction.add(:withings_subscription_created, self)
        logger.warn "subscription created"
      else
        self.update_attributes({:withings_subscription_renew_by => Date.today+1.day})        
        logger.warn "subscription failed"
      end
      return true
    end
    
    def self.update_withings_subscriptions
      User.where('withings_subscription_renew_by <= ?', Time.zone.today+2.days).each do |user|
        user.subscribe_withings
      end
    end
    
    def close_account_and_destroy_everything
        Checkin.destroy_all(:user_id => self.id)
        Entry.destroy_all(:user_id => self.id)
        Invitation.destroy_all(:user_id => self.id)
        #Invitation.destroy_all(:invited_user_id => self.id)
        LocationContext.destroy_all(:user_id => self.id)
        Notification.destroy_all(:user_id => self.id)
        OauthToken.destroy_all(:user_id => self.id)
        Relationship.destroy_all(:user_id => self.id)
        Relationship.destroy_all(:followed_user_id => self.id)
        StreamItem.destroy_all(:user_id => self.id)
        TrackedAction.destroy_all(:user_id => self.id)
        UserAddon.destroy_all(:user_id => self.id)
        UserAction.destroy_all(:user_id => self.id)
        UserLike.destroy_all(:user_id => self.id)
        UserComment.destroy_all(:user_id => self.id)
        UserTrait.destroy_all(:user_id => self.id)
        PlayerMessage.destroy_all(:from_user_id => self.id)
        PlayerMessage.destroy_all(:to_user_id => self.id)
        Braintree::Customer.delete(self.id.to_s) if self.has_braintree.present?
        self.destroy    
    end
    
    # Fetches the date the user last logged in
    #
    # @return [String] YYYY-MM-DD format
    def get_latest_login_date
      self.last_logged_in.nil? ? '' : self.last_logged_in.strftime('%Y-%m-%d')
    end
    
    # Fetches the date the user last checked in
    #
    # @return [String] YYYY-MM-DD format    
    def get_latest_checkin_date
      program_players=self.get_program_players
      if program_players.nil?
        return ''
      else
        dates=program_players.collect{|pp| pp.last_checked_in}.reject{|d| d.nil?}
        return (dates.empty?) ? '' : dates.max.strftime('%Y-%m-%d')
      end
    end
    
    # fetches the user's program players in active programs
    def get_program_players
      self.program_players.order('last_checked_in DESC').select{|pp|pp.program.present? and pp.program.featured?}
    end
    
    # has a user has checked in an action yet
    def done_anything_yet?
      if self.hasnt_bought_anything_yet?
        false
      else
        self.get_program_players.collect{|pp| pp.done_anything_yet?}.any?
      end
    end
    
    # is a user scheduled in the next week for all of their programs
    def is_scheduled_soon?
      self.get_program_players.collect{|pp| pp.scheduled_within(7.days)}.all?
    end
    
    # is a user between levels, with no scheduled start date, for any of their programs
    def in_level_limbo?
      self.get_program_players.collect{|pp| pp.in_limbo?}.any?
    end
    
    def engaged?
      if self.in_beta
        self.get_program_players.collect{|pp| pp.has_checked_in_last(3.days)}.any?
      else
        false
      end
    end
    
    def is_long_lost?
      self.get_program_players.collect{|pp| pp.is_long_lost?}.all?
    end

    @@STATES=['interested', 'no programs', 'no actions', 'engaged', 'snoozing', 'scheduled', 'level limbo', 'off-wagon', 'long-lost','unknown']
    # figure out which state the user is in
    # possible states are:
    # {interested, no programs, no actions, engaged, scheduled, level limbo, off-wagon, long-lost}
    # @return [String] name of user state
    # ARG - need to chain checks on previous state in list for all the sub-methods
    def get_state
      state='unknown'
      if not self.in_beta
        state='interested'
      elsif self.hasnt_bought_anything_yet?
        state='no programs'
      elsif not self.done_anything_yet?
        state='no actions'
      elsif self.engaged?
        state='engaged'
      elsif self.is_scheduled_soon?
        state='scheduled'
      elsif self.in_level_limbo?
        state='level limbo'
      elsif self.is_long_lost?
        state='long-lost'
      else
        state='off-wagon'
      end
      return state
    end
    def self.update_state_for_all_users
      User.all.each do |user|
        user.update_attributes(:status => user.get_state)
      end
    end
    
    def self.get_state_counts_on_cohort(user_cohort)
      states={}
      @@STATES.each{|s| states[s]=0}
      states['total_size']=user_cohort.size
      user_cohort.each{|user| states[user.status]+=1}
      return states
    end
      
    # does the user get beyond the activation flow: becoming a beta user, enrolling in a program, and doing an action
    def is_activated?
      not ['interested', 'no programs', 'no actions'].includes? self.status
    end

    #was a user activated (did they do one action) by the date given
    def was_activated_by(date=Date.today)
      self.get_program_players.collect{|pp| pp.was_activated_by(date)}.any?
    end
    
    
    def get_program_names_list
      self.get_program_players.map{|pp| pp.program.name unless pp.program.nil?}.join(", ")
    end
    
    
    # get a hash of the auto messages sent and scheduled by each program back until a set amount of time
    # the hash is keyed by the program id    
    def get_timed_auto_messages(start_time=30.days.ago)
      messages={}
      self.get_program_players.each{|pp| messages[pp.program.id]=pp.get_timed_auto_messages(start_time)}
      return messages
    end
    
    # get a hash of the player messages sent and scheduled by each program back until a set amount of time
    # the hash is keyed by the program id    
    def get_messages(start_time=30.days.ago)
      messages={}
      self.get_program_players.each do |pp|
        messages[pp.program.id]=pp.get_messages(start_time) unless pp.program.nil?
      end
      return messages
    end
    def get_messages_info(messages)
      info={}
      messages.each do |prog_id,messages|
        # info[prog_id]=messages
        info[prog_id]=messages.map do |m|
          {
            :id=>m.id,
            :level_id=>m.player_budge.id,
            :deliver_at=>m.deliver_at,
            :content=>m.content,
            :level_number=>m.level_number
          }
        end
      end
      return info
    end
      
    
    def get_checkins(start_time=30.days.ago)
      checkins={}
      self.get_program_players.select{|pp|pp.program.present?}.each{|pp| checkins[pp.program.id]=pp.get_checkins(start_time)}
      return checkins
    end
    def get_checkins_info(checkins)
      info={}
      checkins.each do |prog_id,checkins|
        info[prog_id]=checkins.map do |c|
          {
            :id=>c.id,
            :level_id=>c.player_budge.id,
            :amount_decimal=>c.amount_decimal,
            :created_at=>c.created_at,
            :level_number=>c.level_number
          }
        end
      end
      return info
    end
        
      
    
    
    def get_level_attempts(start_time=30.days.ago,end_time=30.days.from_now)
      budges={}
      self.get_program_players.each{|pp| budges[pp.program.id]= pp.player_budges.where(:start_date=>(start_time .. end_time)) unless pp.program.nil?}
      return budges
    end
    def get_level_attempts_info(level_attempts)
      budges_info={}
      level_attempts.each do |prog_id,prog_budges|
        budges_info[prog_id]=[]
        prog_budges.each do |b|
          next if b.start_date.nil? or b.level_number.nil? or b.finish_date.nil?
          
          budges_info[prog_id].push(
            {
              :id=>b.id,
              :start_date=>b.start_date,
              :end_date=> b.finish_date,
              :end_date_display=>b.finish_date+1.day, #day ends at midnight
              :level_number=>b.level_number
            }
          )
        end
      end
      return budges_info
    end
    
    
    
    COUNTRIES = {
      "Afghanistan" => {:short => 'AF', :long => 'AFG', :code => '004'},
      "Aland" => {:short => 'AX', :long => 'ALA', :code => '248'},    
      "Albania" => {:short => 'AL', :long => 'ALB', :code => '008'},
      "Algeria" => {:short => 'DZ', :long => 'DZA', :code => '012'},
      "American Samoa" => {:short => 'AS', :long => 'ASM', :code => '016'},
      "Andorra" => {:short => 'AD', :long => 'AND', :code => '020'},
      "Angola" => {:short => 'AO', :long => 'AGO', :code => '024'},
      "Anguilla" => {:short => 'AI', :long => 'AIA', :code => '660'},
      "Antarctica" => {:short => 'AQ', :long => 'ATA', :code => '010'},
      "Antigua and Barbuda" => {:short => 'AG', :long => 'ATG', :code => '028'},
      "Argentina" => {:short => 'AR', :long => 'ARG', :code => '032'},
      "Armenia" => {:short => 'AM', :long => 'ARM', :code => '051'},
      "Aruba" => {:short => 'AW', :long => 'ABW', :code => '533'},
      "Australia" => {:short => 'AU', :long => 'AUS', :code => '036'},
      "Austria" => {:short => 'AT', :long => 'AUT', :code => '040'},
      "Azerbaijan" => {:short => 'AZ', :long => 'AZE', :code => '031'},
      "Bahamas" => {:short => 'BS', :long => 'BHS', :code => '044'},
      "Bahrain" => {:short => 'BH', :long => 'BHR', :code => '048'},
      "Bangladesh" => {:short => 'BD', :long => 'BGD', :code => '050'},
      "Barbados" => {:short => 'BB', :long => 'BRB', :code => '052'},
      "Belarus" => {:short => 'BY', :long => 'BLR', :code => '112'},
      "Belgium" => {:short => 'BE', :long => 'BEL', :code => '056'},
      "Belize" => {:short => 'BZ', :long => 'BLZ', :code => '084'},
      "Benin" => {:short => 'BJ', :long => 'BEN', :code => '204'},
      "Bermuda" => {:short => 'BM', :long => 'BMU', :code => '060'},
      "Bhutan" => {:short => 'BT', :long => 'BTN', :code => '064'},
      "Bolivia" => {:short => 'BO', :long => 'BOL', :code => '068'},
      "Bosnia and Herzegovina" => {:short => 'BA', :long => 'BIH', :code => '070'},
      "Botswana" => {:short => 'BW', :long => 'BWA', :code => '072'},
      "Bouvet Island" => {:short => 'BV', :long => 'BVT', :code => '074'},
      "Brazil" => {:short => 'BR', :long => 'BRA', :code => '076'},
      "British Indian Ocean Territory" => {:short => 'IO', :long => 'IOT', :code => '086'},
      "Brunei Darussalam" => {:short => 'BN', :long => 'BRN', :code => '096'},
      "Bulgaria" => {:short => 'BG', :long => 'BGR', :code => '100'},
      "Burkina Faso" => {:short => 'BF', :long => 'BFA', :code => '854'},
      "Burundi" => {:short => 'BI', :long => 'BDI', :code => '108'},
      "Cambodia" => {:short => 'KH', :long => 'KHM', :code => '116'},
      "Cameroon" => {:short => 'CM', :long => 'CMR', :code => '120'},
      "Canada" => {:short => 'CA', :long => 'CAN', :code => '124'},
      "Cape Verde" => {:short => 'CV', :long => 'CPV', :code => '132'},
      "Cayman Islands" => {:short => 'KY', :long => 'CYM', :code => '136'},
      "Central African Republic" => {:short => 'CF', :long => 'CAF', :code => '140'},
      "Chad" => {:short => 'TD', :long => 'TCD', :code => '148'},
      "Chile" => {:short => 'CL', :long => 'CHL', :code => '152'},
      "China" => {:short => 'CN', :long => 'CHN', :code => '156'},
      "Christmas Island" => {:short => 'CX', :long => 'CXR', :code => '162'},
      "Cocos (Keeling) Islands" => {:short => 'CC', :long => 'CCK', :code => '166'},
      "Colombia" => {:short => 'CO', :long => 'COL', :code => '170'},
      "Comoros" => {:short => 'KM', :long => 'COM', :code => '174'},
      "Congo (Brazzaville)" => {:short => 'CG', :long => 'COG', :code => '178'},
      "Congo (Kinshasa)" => {:short => 'CD', :long => 'COD', :code => '180'},
      "Cook Islands" => {:short => 'CK', :long => 'COK', :code => '184'},
      "Costa Rica" => {:short => 'CR', :long => 'CRI', :code => '188'},
      "Croatia" => {:short => 'HR', :long => 'HRV', :code => '191'},
      "Cuba" => {:short => 'CU', :long => 'CUB', :code => '192'},
      "Cyprus" => {:short => 'CY', :long => 'CYP', :code => '196'},
      "Czech Republic" => {:short => 'CZ', :long => 'CZE', :code => '203'},
      "Cote d'Ivoire" => {:short => 'CI', :long => 'CIV', :code => '384'},
      "Denmark" => {:short => 'DK', :long => 'DNK', :code => '208'},
      "Djibouti" => {:short => 'DJ', :long => 'DJI', :code => '262'},
      "Dominica" => {:short => 'DM', :long => 'DMA', :code => '212'},
      "Dominican Republic" => {:short => 'DO', :long => 'DOM', :code => '214'},
      "Ecuador" => {:short => 'EC', :long => 'ECU', :code => '218'},
      "Egypt" => {:short => 'EG', :long => 'EGY', :code => '818'},
      "El Salvador" => {:short => 'SV', :long => 'SLV', :code => '222'},
      "Equatorial Guinea" => {:short => 'GQ', :long => 'GNQ', :code => '226'},
      "Eritrea" => {:short => 'ER', :long => 'ERI', :code => '232'},
      "Estonia" => {:short => 'EE', :long => 'EST', :code => '233'},
      "Ethiopia" => {:short => 'ET', :long => 'ETH', :code => '231'},
      "Falkland Islands" => {:short => 'FK', :long => 'FLK', :code => '238'},
      "Faroe Islands" => {:short => 'FO', :long => 'FRO', :code => '234'},
      "Fiji" => {:short => 'FJ', :long => 'FJI', :code => '242'},
      "Finland" => {:short => 'FI', :long => 'FIN', :code => '246'},
      "France" => {:short => 'FR', :long => 'FRA', :code => '250'},
      "French Guiana" => {:short => 'GF', :long => 'GUF', :code => '254'},
      "French Polynesia" => {:short => 'PF', :long => 'PYF', :code => '258'},
      "French Southern Lands" => {:short => 'TF', :long => 'ATF', :code => '260'},
      "Gabon" => {:short => 'GA', :long => 'GAB', :code => '266'},
      "Gambia" => {:short => 'GM', :long => 'GMB', :code => '270'},
      "Georgia" => {:short => 'GE', :long => 'GEO', :code => '268'},
      "Germany" => {:short => 'DE', :long => 'DEU', :code => '276'},
      "Ghana" => {:short => 'GH', :long => 'GHA', :code => '288'},
      "Gibraltar" => {:short => 'GI', :long => 'GIB', :code => '292'},
      "Greece" => {:short => 'GR', :long => 'GRC', :code => '300'},
      "Greenland" => {:short => 'GL', :long => 'GRL', :code => '304'},
      "Grenada" => {:short => 'GD', :long => 'GRD', :code => '308'},
      "Guadeloupe" => {:short => 'GP', :long => 'GLP', :code => '312'},
      "Guam" => {:short => 'GU', :long => 'GUM', :code => '316'},
      "Guatemala" => {:short => 'GT', :long => 'GTM', :code => '320'},
      "Guernsey" => {:short => 'GG', :long => 'GGY', :code => '831'},
      "Guinea" => {:short => 'GN', :long => 'GIN', :code => '324'},
      "Guinea-Bissau" => {:short => 'GW', :long => 'GNB', :code => '624'},
      "Guyana" => {:short => 'GY', :long => 'GUY', :code => '328'},
      "Haiti" => {:short => 'HT', :long => 'HTI', :code => '332'},
      "Heard and McDonald Islands" => {:short => 'HM', :long => 'HMD', :code => '334'},
      "Honduras" => {:short => 'HN', :long => 'HND', :code => '340'},
      "Hong Kong" => {:short => 'HK', :long => 'HKG', :code => '344'},
      "Hungary" => {:short => 'HU', :long => 'HUN', :code => '348'},
      "Iceland" => {:short => 'IS', :long => 'ISL', :code => '352'},
      "India" => {:short => 'IN', :long => 'IND', :code => '356'},
      "Indonesia" => {:short => 'ID', :long => 'IDN', :code => '360'},
      "Iran" => {:short => 'IR', :long => 'IRN', :code => '364'},
      "Iraq" => {:short => 'IQ', :long => 'IRQ', :code => '368'},
      "Ireland" => {:short => 'IE', :long => 'IRL', :code => '372'},
      "Isle of Man" => {:short => 'IM', :long => 'IMN', :code => '833'},
      "Israel" => {:short => 'IL', :long => 'ISR', :code => '376'},
      "Italy" => {:short => 'IT', :long => 'ITA', :code => '380'},
      "Jamaica" => {:short => 'JM', :long => 'JAM', :code => '388'},
      "Japan" => {:short => 'JP', :long => 'JPN', :code => '392'},
      "Jersey" => {:short => 'JE', :long => 'JEY', :code => '832'},
      "Jordan" => {:short => 'JO', :long => 'JOR', :code => '400'},
      "Kazakhstan" => {:short => 'KZ', :long => 'KAZ', :code => '398'},
      "Kenya" => {:short => 'KE', :long => 'KEN', :code => '404'},
      "Kiribati" => {:short => 'KI', :long => 'KIR', :code => '296'},
      "Korea, North" => {:short => 'KP', :long => 'PRK', :code => '408'},
      "Korea, South" => {:short => 'KR', :long => 'KOR', :code => '410'},
      "Kuwait" => {:short => 'KW', :long => 'KWT', :code => '414'},
      "Kyrgyzstan" => {:short => 'KG', :long => 'KGZ', :code => '417'},
      "Laos" => {:short => 'LA', :long => 'LAO', :code => '418'},
      "Latvia" => {:short => 'LV', :long => 'LVA', :code => '428'},
      "Lebanon" => {:short => 'LB', :long => 'LBN', :code => '422'},
      "Lesotho" => {:short => 'LS', :long => 'LSO', :code => '426'},
      "Liberia" => {:short => 'LR', :long => 'LBR', :code => '430'},
      "Libya" => {:short => 'LY', :long => 'LBY', :code => '434'},
      "Liechtenstein" => {:short => 'LI', :long => 'LIE', :code => '438'},
      "Lithuania" => {:short => 'LT', :long => 'LTU', :code => '440'},
      "Luxembourg" => {:short => 'LU', :long => 'LUX', :code => '442'},
      "Macau" => {:short => 'MO', :long => 'MAC', :code => '446'},
      "Macedonia" => {:short => 'MK', :long => 'MKD', :code => '807'},
      "Madagascar" => {:short => 'MG', :long => 'MDG', :code => '450'},
      "Malawi" => {:short => 'MW', :long => 'MWI', :code => '454'},
      "Malaysia" => {:short => 'MY', :long => 'MYS', :code => '458'},
      "Maldives" => {:short => 'MV', :long => 'MDV', :code => '462'},
      "Mali" => {:short => 'ML', :long => 'MLI', :code => '466'},
      "Malta" => {:short => 'MT', :long => 'MLT', :code => '470'},
      "Marshall Islands" => {:short => 'MH', :long => 'MHL', :code => '584'},
      "Martinique" => {:short => 'MQ', :long => 'MTQ', :code => '474'},
      "Mauritania" => {:short => 'MR', :long => 'MRT', :code => '478'},
      "Mauritius" => {:short => 'MU', :long => 'MUS', :code => '480'},
      "Mayotte" => {:short => 'YT', :long => 'MYT', :code => '175'},
      "Mexico" => {:short => 'MX', :long => 'MEX', :code => '484'},
      "Micronesia" => {:short => 'FM', :long => 'FSM', :code => '583'},
      "Moldova" => {:short => 'MD', :long => 'MDA', :code => '498'},
      "Monaco" => {:short => 'MC', :long => 'MCO', :code => '492'},
      "Mongolia" => {:short => 'MN', :long => 'MNG', :code => '496'},
      "Montenegro" => {:short => 'ME', :long => 'MNE', :code => '499'},
      "Montserrat" => {:short => 'MS', :long => 'MSR', :code => '500'},
      "Morocco" => {:short => 'MA', :long => 'MAR', :code => '504'},
      "Mozambique" => {:short => 'MZ', :long => 'MOZ', :code => '508'},
      "Myanmar" => {:short => 'MM', :long => 'MMR', :code => '104'},
      "Namibia" => {:short => 'NA', :long => 'NAM', :code => '516'},
      "Nauru" => {:short => 'NR', :long => 'NRU', :code => '520'},
      "Nepal" => {:short => 'NP', :long => 'NPL', :code => '524'},
      "Netherlands" => {:short => 'NL', :long => 'NLD', :code => '528'},
      "Netherlands Antilles" => {:short => 'AN', :long => 'ANT', :code => '530'},
      "New Caledonia" => {:short => 'NC', :long => 'NCL', :code => '540'},
      "New Zealand" => {:short => 'NZ', :long => 'NZL', :code => '554'},
      "Nicaragua" => {:short => 'NI', :long => 'NIC', :code => '558'},
      "Niger" => {:short => 'NE', :long => 'NER', :code => '562'},
      "Nigeria" => {:short => 'NG', :long => 'NGA', :code => '566'},
      "Niue" => {:short => 'NU', :long => 'NIU', :code => '570'},
      "Norfolk Island" => {:short => 'NF', :long => 'NFK', :code => '574'},
      "Northern Mariana Islands" => {:short => 'MP', :long => 'MNP', :code => '580'},
      "Norway" => {:short => 'NO', :long => 'NOR', :code => '578'},
      "Oman" => {:short => 'OM', :long => 'OMN', :code => '512'},
      "Pakistan" => {:short => 'PK', :long => 'PAK', :code => '586'},
      "Palau" => {:short => 'PW', :long => 'PLW', :code => '585'},
      "Palestine" => {:short => 'PS', :long => 'PSE', :code => '275'},
      "Panama" => {:short => 'PA', :long => 'PAN', :code => '591'},
      "Papua New Guinea" => {:short => 'PG', :long => 'PNG', :code => '598'},
      "Paraguay" => {:short => 'PY', :long => 'PRY', :code => '600'},
      "Peru" => {:short => 'PE', :long => 'PER', :code => '604'},
      "Philippines" => {:short => 'PH', :long => 'PHL', :code => '608'},
      "Pitcairn" => {:short => 'PN', :long => 'PCN', :code => '612'},
      "Poland" => {:short => 'PL', :long => 'POL', :code => '616'},
      "Portugal" => {:short => 'PT', :long => 'PRT', :code => '620'},
      "Puerto Rico" => {:short => 'PR', :long => 'PRI', :code => '630'},
      "Qatar" => {:short => 'QA', :long => 'QAT', :code => '634'},
      "Reunion" => {:short => 'RE', :long => 'REU', :code => '638'},
      "Romania" => {:short => 'RO', :long => 'ROU', :code => '642'},
      "Russian Federation" => {:short => 'RU', :long => 'RUS', :code => '643'},
      "Rwanda" => {:short => 'RW', :long => 'RWA', :code => '646'},
      "Saint Barthelemy" => {:short => 'BL', :long => 'BLM', :code => '652'},
      "Saint Helena" => {:short => 'SH', :long => 'SHN', :code => '654'},
      "Saint Kitts and Nevis" => {:short => 'KN', :long => 'KNA', :code => '659'},
      "Saint Lucia" => {:short => 'LC', :long => 'LCA', :code => '662'},
      "Saint Martin (French part)" => {:short => 'MF', :long => 'MAF', :code => '663'},
      "Saint Pierre and Miquelon" => {:short => 'PM', :long => 'SPM', :code => '666'},
      "Saint Vincent and the Grenadines" => {:short => 'VC', :long => 'VCT', :code => '670'},
      "Samoa" => {:short => 'WS', :long => 'WSM', :code => '882'},
      "San Marino" => {:short => 'SM', :long => 'SMR', :code => '674'},
      "Sao Tome and Principe" => {:short => 'ST', :long => 'STP', :code => '678'},
      "Saudi Arabia" => {:short => 'SA', :long => 'SAU', :code => '682'},
      "Senegal" => {:short => 'SN', :long => 'SEN', :code => '686'},
      "Serbia" => {:short => 'RS', :long => 'SRB', :code => '688'},
      "Seychelles" => {:short => 'SC', :long => 'SYC', :code => '690'},
      "Sierra Leone" => {:short => 'SL', :long => 'SLE', :code => '694'},
      "Singapore" => {:short => 'SG', :long => 'SGP', :code => '702'},
      "Slovakia" => {:short => 'SK', :long => 'SVK', :code => '703'},
      "Slovenia" => {:short => 'SI', :long => 'SVN', :code => '705'},
      "Solomon Islands" => {:short => 'SB', :long => 'SLB', :code => '090'},
      "Somalia" => {:short => 'SO', :long => 'SOM', :code => '706'},
      "South Africa" => {:short => 'ZA', :long => 'ZAF', :code => '710'},
      "South Georgia and South Sandwich Islands" => {:short => 'GS', :long => 'SGS', :code => '239'},
      "Spain" => {:short => 'ES', :long => 'ESP', :code => '724'},
      "Sri Lanka" => {:short => 'LK', :long => 'LKA', :code => '144'},
      "Sudan" => {:short => 'SD', :long => 'SDN', :code => '736'},
      "Suriname" => {:short => 'SR', :long => 'SUR', :code => '740'},
      "Svalbard and Jan Mayen Islands" => {:short => 'SJ', :long => 'SJM', :code => '744'},
      "Swaziland" => {:short => 'SZ', :long => 'SWZ', :code => '748'},
      "Sweden" => {:short => 'SE', :long => 'SWE', :code => '752'},
      "Switzerland" => {:short => 'CH', :long => 'CHE', :code => '756'},
      "Syria" => {:short => 'SY', :long => 'SYR', :code => '760'},
      "Taiwan" => {:short => 'TW', :long => 'TWN', :code => '158'},
      "Tajikistan" => {:short => 'TJ', :long => 'TJK', :code => '762'},
      "Tanzania" => {:short => 'TZ', :long => 'TZA', :code => '834'},
      "Thailand" => {:short => 'TH', :long => 'THA', :code => '764'},
      "Timor-Leste" => {:short => 'TL', :long => 'TLS', :code => '626'},
      "Togo" => {:short => 'TG', :long => 'TGO', :code => '768'},
      "Tokelau" => {:short => 'TK', :long => 'TKL', :code => '772'},
      "Tonga" => {:short => 'TO', :long => 'TON', :code => '776'},
      "Trinidad and Tobago" => {:short => 'TT', :long => 'TTO', :code => '780'},
      "Tunisia" => {:short => 'TN', :long => 'TUN', :code => '788'},
      "Turkey" => {:short => 'TR', :long => 'TUR', :code => '792'},
      "Turkmenistan" => {:short => 'TM', :long => 'TKM', :code => '795'},
      "Turks and Caicos Islands" => {:short => 'TC', :long => 'TCA', :code => '796'},
      "Tuvalu" => {:short => 'TV', :long => 'TUV', :code => '798'},
      "Uganda" => {:short => 'UG', :long => 'UGA', :code => '800'},
      "Ukraine" => {:short => 'UA', :long => 'UKR', :code => '804'},
      "United Arab Emirates" => {:short => 'AE', :long => 'ARE', :code => '784'},
      "United Kingdom" => {:short => 'GB', :long => 'GBR', :code => '826'},
      "United States Minor Outlying Islands" => {:short => 'UM', :long => 'UMI', :code => '581'},
      "United States of America" => {:short => 'US', :long => 'USA', :code => '840'},
      "Uruguay" => {:short => 'UY', :long => 'URY', :code => '858'},
      "Uzbekistan" => {:short => 'UZ', :long => 'UZB', :code => '860'},
      "Vanuatu" => {:short => 'VU', :long => 'VUT', :code => '548'},
      "Vatican City" => {:short => 'VA', :long => 'VAT', :code => '336'},
      "Venezuela" => {:short => 'VE', :long => 'VEN', :code => '862'},
      "Vietnam" => {:short => 'VN', :long => 'VNM', :code => '704'},
      "Virgin Islands, British" => {:short => 'VG', :long => 'VGB', :code => '092'},
      "Virgin Islands, U.S." => {:short => 'VI', :long => 'VIR', :code => '850'},
      "Wallis and Futuna Islands" => {:short => 'WF', :long => 'WLF', :code => '876'},
      "Western Sahara" => {:short => 'EH', :long => 'ESH', :code => '732'},
      "Yemen" => {:short => 'YE', :long => 'YEM', :code => '887'},
      "Zambia" => {:short => 'ZM', :long => 'ZMB', :code => '894'},
      "Zimbabwe" => {:short => 'ZW', :long => 'ZWE', :code => '716'}
    }
    
end




# == Schema Information
#
# Table name: users
#
#  id                             :integer(4)      not null, primary key
#  name                           :string(255)
#  email                          :string(255)
#  hashed_password                :string(255)
#  salt                           :string(255)
#  time_zone                      :string(255)
#  gender                         :string(255)
#  birthday_day                   :integer(4)
#  birthday_month                 :integer(4)
#  birthday_year                  :integer(4)
#  email_verified                 :boolean(1)      default(FALSE)
#  photo_file_name                :string(255)
#  photo_content_type             :string(255)
#  photo_file_size                :integer(4)
#  get_notifications              :boolean(1)      default(TRUE)
#  get_news                       :boolean(1)      default(TRUE)
#  no_notifications_before        :integer(4)      default(8)
#  no_notifications_after         :integer(4)      default(22)
#  last_logged_in                 :datetime
#  use_metric                     :boolean(1)      default(FALSE)
#  bio                            :text
#  created_at                     :datetime
#  updated_at                     :datetime
#  facebook_uid                   :string(255)
#  admin                          :boolean(1)      default(FALSE)
#  relationship_status            :string(255)
#  level_up_credits               :integer(4)      default(0)
#  num_notifications              :integer(4)      default(0)
#  total_level_up_credits_earned  :integer(4)      default(0)
#  meta_level                     :integer(4)      default(0)
#  phone                          :string(255)
#  phone_normalized               :string(255)
#  phone_verified                 :boolean(1)      default(FALSE)
#  facebook_username              :string(255)
#  twitter_username               :string(255)
#  contact_by_email_pref          :integer(4)      default(10)
#  contact_by_sms_pref            :integer(4)      default(10)
#  contact_by_public_tweet_pref   :integer(4)      default(5)
#  contact_by_dm_tweet_pref       :integer(4)      default(5)
#  contact_by_robocall_pref       :integer(4)      default(0)
#  contact_by_email_score         :decimal(10, 8)  default(10.0)
#  contact_by_sms_score           :decimal(10, 8)  default(10.0)
#  contact_by_public_tweet_score  :decimal(10, 8)  default(10.0)
#  contact_by_dm_tweet_score      :decimal(10, 8)  default(10.0)
#  contact_by_robocall_score      :decimal(10, 8)  default(10.0)
#  visit_streak                   :integer(4)      default(0)
#  contact_by_facebook_wall_pref  :decimal(10, 8)  default(5.0)
#  contact_by_facebook_wall_score :decimal(10, 8)  default(10.0)
#  contact_by_friend_pref         :decimal(10, 8)  default(1.0)
#  contact_by_friend_score        :decimal(10, 8)  default(10.0)
#  meta_level_alignment           :integer(4)
#  meta_level_role                :string(255)
#  meta_level_name                :string(255)
#  addon_cache                    :text
#  coach                          :boolean(1)      default(FALSE)
#  visit_stats_updated            :datetime
#  visit_stats_sample_size        :integer(4)      default(0)
#  streak_level                   :integer(4)      default(0)
#  has_braintree                  :boolean(1)      default(FALSE)
#  distance_units                 :integer(4)      default(0)
#  weight_units                   :integer(4)      default(0)
#  currency_units                 :integer(4)      default(0)
#  withings_user_id               :string(255)
#  withings_public_key            :string(255)
#  withings_username              :string(255)
#  withings_subscription_renew_by :date
#  last_latitude                  :decimal(15, 10)
#  last_longitude                 :decimal(15, 10)
#  lat_long_updated_at            :datetime
#  next_nudge_at                  :datetime
#  in_beta                        :boolean(1)      default(FALSE)
#  last_location_context_id       :integer(4)
#  dollars_credit                 :decimal(8, 2)   default(0.0)
#  send_phone_verification        :boolean(1)      default(FALSE)
#  status                         :string(255)     default("interested")
#  officially_started_at          :datetime
#  cohort_tag                     :string(255)
#  invited_to_beta                :boolean(1)      default(FALSE)
#

