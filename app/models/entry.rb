class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :program
  belongs_to :program_player
  belongs_to :program_budge
  belongs_to :player_budge
  belongs_to :checkin # for programless_checkins
  belongs_to :location_context
  has_many :comments, :class_name => 'EntryComment'
  has_many :likes
  
  after_create :save_metadata, :post_remotely
  
  serialize :metadata
  
  PRIVACY_PRIVATE = 0
  PRIVACY_PUBLIC = 10
  PRIVACY = {0 => {:name => "Private"},
             1 => {:name => "Friends only"},
             2 => {:name => "Program players only"},
             3 => {:name => "Friends and program players"},
             10 => {:name => "Public"}}

  def time_ago
    seconds_ago = Time.now.utc - self.created_at
    
    if seconds_ago < 60
      return "#{seconds_ago.to_i}s"
    elsif seconds_ago < 60*60
      return "#{(seconds_ago/60).to_i}m"
    elsif seconds_ago < 60*60*24
      return "#{(seconds_ago/60/60).to_i}h"
    elsif seconds_ago < 60*60*24*7
      return "#{(seconds_ago/60/60/24).to_i}d"
    elsif seconds_ago < 60*60*24*7*4
      return "#{(seconds_ago/60/60/24/7).to_i}w"
    elsif seconds_ago < 60*60*24*30.5
      return "#{(seconds_ago/60/60/24/30.5).to_i}m"
    else 
      return "#{(seconds_ago/60/60/24/365.25).to_i}y"
    end
  end

  def save_metadata
    
    # Declared end of program
    if self.message_type == 'declare_end'
      self.metadata = {:answers => {}, :leader_stats => {}, :declaration => (self.program_player.victorious? ? :victory : :defeat)}
      leader_stats = Hash.new
      Leader.where(:user_id => self.user_id, :program_id => self.program_id).order(:date).each do |leader|
        leader_stats[leader.date] = {:score => leader.score}
      end
      self.metadata[:answers] = {:answer_1 => self.program_player.required_answer_1,
                                 :answer_2 => self.program_player.required_answer_2,
                                 :answer_3 => self.program_player.optional_answer_1,
                                 :answer_4 => self.program_player.optional_answer_2}
      self.metadata[:leader_stats] = leader_stats
      self.save
    
    # Checkin
    elsif self.player_budge.present? 
      self.metadata = {:checkins => {}, :unique_checkin_dates => 0}
      self.metadata = self.player_budge.checkin_metadata_summary(self.date)
      self.save
      self.program_player.update_leaderboard_score
    

    # Programless checkin
    elsif self.message_type == 'programless_checkin' and self.checkin.present?
      self.metadata = {:checkins => {}, :unique_checkin_dates => 0}

      unique_dates = self.checkin.unique_checkin_dates(self.date, 30)
      self.metadata[:unique_checkin_string] = unique_dates[:string]
      self.metadata[:unique_checkin_dates] = unique_dates[:num_unique_dates]
      self.metadata[:checkins][self.checkin_id] = self.checkin.get_metadata_summary
      self.save
    
    end
  end
    
  # Used by entry#notify_coaches_of_checkin => mailer#contact_them:coached_player_checked_in
  def summary_from_metadata
    messages = self.summary_messages_from_metadata
    return "#{self.user.name} #{summary_messages_from_metadata.join(', ')}".gsub(/\s+/,' ')
  end
  def summary_messages_from_metadata
    return ["checked in to #{self.program.name}"] unless self.metadata.present? and self.metadata[:checkins].present?
    messages = Array.new
    
    self.metadata[:checkins].map do |c,h|
      message = h[:statement]
      if trait = Trait.find(h[:trait_id])
        if trait.cumulative_results?
          message += " (30 days: #{h[:summary_total]})"
        else
          message += " (30 day avg is #{h[:summary_average]} #{self.user.weight_pref})"
        end
      end
      messages << message
    end
    return messages
  end

  # DISABLED
  # def notify_coaches_of_checkin
  #   # Notify coaches and supporters of the checkin 
  #   people_notified = Hash.new    
  #   if program_player.present? and program_player.program_coach.present?
  #     program_player.program_coach.user.contact_them(:sms, :coached_player_checked_in, self)
  #     people_notified[program_player.program_coach.user_id] = true
  #   end
  #   
  #   # Let friend coaches know
  #   if false and program_player.active_supporters.present?
  #     program_player.active_supporters.each do |supporter|
  #       if supporter.user.present? and !people_notified[supporter.user_id]
  #         supporter.user.contact_them(:sms, :coached_player_checked_in, self)
  #         people_notified[supporter.user_id] = true        
  #       end
  #     end
  #   end  
  # end

  def post_remotely
    if Rails.env.production?
      self.delay.post_remotely_as_delayed_job
    else
      self.post_remotely_as_delayed_job
    end
  end
    
  # Will not be sent out publicly on development, or during PRIVATE_BETA
  def post_remotely_as_delayed_job
  
    # The link will be of type "entry", and will be redirected in StreamController:
    # 'starting_soon' => sends people to the store's program page store#program
    # 'checkin' => sends people to the public entry page stream#entry
  
    # The options hash needs:
    # :okay_to_post (overrides private_beta flag)
    # :for_object
    # :for_id
    # :message
    # :name (facebook)
    # :caption (facebook)
    # :latitude
    # :longitude
    # :foursquare_place_id (foursquare)
    message_hash = {:okay_to_post => Rails.env.production?,
                    :for_object => 'entry',
                    :for_id => self.id,
                    :message => self.message,
                    :name => (self.program.present? ? self.program.name : "Budge"),
                    :caption => "Budge helps you do things you didn't think you could!",
                    :latitude => (self.location_context.present? ? self.location_context.latitude : nil),
                    :longitude => (self.location_context.present? ? self.location_context.longitude : nil)}
      
    # PlayerMessage
    if self.post_to_coach? and self.program_player.present?
      program_coach = self.program_player.program_coach rescue nil
      if program_coach.present?
        @send_to = program_coach
        @send_to_coach = true
      elsif self.program_player.supporters.where(:active => true).present?
        @send_to = self.program_player.supporters.where(:active => true).first
        @send_to_supporter = true
      end
      
      if program_player.player_budge and program_player.player_budge.program_budge_id == self.program_budge_id
        player_budge = program_player.player_budge
      end
      player_message = PlayerMessage.create({:from_user_id => self.user_id,
                                             :to_user_id => (@send_to ? @send_to.user_id : nil),
                                             :content => self.message,
                                             :program_player_id => self.program_player_id,
                                             :player_budge_id => (player_budge.present? ? player_budge.id : nil),
                                             :deliver_via_pref => PlayerMessage::WEBSITE,
                                             :delivered_via => PlayerMessage::WEBSITE,
                                             :delivered => true,
                                             :to_coach => @send_to_coach,
                                             :to_supporters => @send_to_supporter,
                                             :to_player => false,
                                             :program_id => self.program_id,
                                             :program_budge_id => self.program_budge_id,
                                             :deliver_at => Time.now.utc})
    end
    
    # Post to Twitter
    if self.post_to_twitter? 
      if Rails.env.production? and !PRIVATE_BETA
        twitter_oauth_token = self.user.oauth_for_site_token('twitter') rescue nil  
      else
        twitter_oauth_token = OauthToken.budge_token('twitter') rescue nil
      end
      logger.warn twitter_oauth_token.inspect      
      if twitter_oauth_token.present?
        self.tweet_id = twitter_oauth_token.broadcast_to_network(message_hash)
      end    
    end
    
    # Post to Facebook
    if self.post_to_facebook?
      facebook_oauth_token = self.user.oauth_for_site_token('facebook') rescue nil
      if facebook_oauth_token.present? and Rails.env.production? and !PRIVATE_BETA
        facebook_oauth_token = self.user.oauth_for_site_token('facebook') rescue nil  
      else
        facebook_oauth_token = OauthToken.budge_token('facebook') rescue nil
      end
      logger.warn facebook_oauth_token.inspect
      p facebook_oauth_token.inspect
      
      if facebook_oauth_token.present?
        self.facebook_post_id = facebook_oauth_token.broadcast_to_network(message_hash)
      end
    end
    self.save if self.player_message_id.present? or self.tweet_id.present? or self.facebook_post_id.present?
    
    if Rails.env.production? and self.privacy_setting == Entry::PRIVACY_PUBLIC
      super_followers = Relationship.where(:followed_user_id => self.user_id, :super_follow => true)
      super_followers.each do |relationship|
        if relationship.active? and relationship.user.can_sms?
          relationship.user.contact_them(:sms, :super_follow_checkin, self)
        end
      end
    end
    return true
  end  
  
  def self.migrate_comments
    Entry.where(:message_type => :comment).order(:created_at).each do |entry|
      EntryComment.create({:entry_id => entry.parent_id,
                           :user_id => entry.user_id,
                           :location_context_id => entry.location_context_id,
                           :message => entry.message,
                           :created_at => entry.created_at})
    end
  end
  
  #get the number of clicks from the link in an entry that got shared back to budge
  def get_clicks
    notification=self.user.notifications.where(:for_id=>self.id).first
    notification.nil? ? nil : notification.total_clicks
    # self.user.notifications
    # p self.user.notifications.find(:all).first
    # return 0
  end

  def statement
    statement_string = ''
    
    # Declaring victory or defeat
    if self.message_type == 'declare_end'
      statement_string += "#{self.user.name} has declared " +
                          (self.metadata[:declaration] == :victory ? 'victory on' : 'defeat with') + ' ' +
                          self.program.name
        
    # Program-specific checkin entry
    elsif self.program.present?
      if self.metadata.present? and self.metadata[:checkins].present?
        has_text_answers = self.metadata[:checkins].select{|c,h|h[:answer_type] == ':text'}.count > 0
        if has_text_answers
          self.metadata[:checkins].each do |checkin_id, checkin_hash|
            next unless checkin_hash[:answer_type] == ':text'
            checkin = Checkin.find(checkin_id)
            if checkin.checkin_via == 'player' # Answered a question in the app
              statement_string += self.user.name
              statement_string += ' ' + checkin.raw_text if checkin.raw_text.present?
            elsif checkin.raw_text.present? # From twitter or sms, just show full response
              statement_string += checkin.raw_text if checkin.raw_text.present?
            end
          end
        else
          statement_string += self.user.name
          statement_string += ' ' + self.metadata[:checkins].map{|c,h|h[:statement]}.join(' & ')  
        end
        
      else
        statement_string += self.user.name + " checked in to " + self.program.name
      end
      
    # Programless checkin self
    elsif self.checkin.present?
      statement_string += self.checkin.raw_text if self.checkin.raw_text.present?
    end
  
    return statement_string
  end
    
end


# == Schema Information
#
# Table name: entries
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)      not null
#  program_player_id   :integer(4)
#  program_id          :integer(4)
#  program_budge_id    :integer(4)
#  player_message_id   :integer(4)
#  tweet_id            :string(255)
#  facebook_post_id    :string(255)
#  location_context_id :integer(4)
#  message             :text
#  message_type        :string(255)
#  privacy_setting     :integer(4)      default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  post_to_coach       :boolean(1)      default(FALSE)
#  post_to_twitter     :boolean(1)      default(FALSE)
#  post_to_facebook    :boolean(1)      default(FALSE)
#  date                :date
#  player_budge_id     :integer(4)
#  parent_id           :integer(4)
#  original_message    :string(255)
#  metadata            :text
#  checkin_id          :integer(4)
#

