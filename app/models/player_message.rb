class PlayerMessage < ActiveRecord::Base
  belongs_to :to_user, :class_name => 'User'
  belongs_to :from_user, :class_name => 'User'
  belongs_to :program_player
  belongs_to :player_budge
  belongs_to :program
  belongs_to :program_budge
  belongs_to :auto_message
  has_many :player_message_resources
  has_many :link_resources, :through => :player_message_resources
  has_one :entry
  serialize :message_data
  
  before_save :convert_links
  after_create :update_program_player_message_counts
  
  scope :from_budge, :conditions => {:from_user_id=>10} #User.where(:twitter_username=>'Budge').first.id

  # Also in AutoMessage
  DELIVER_VIA = {0 => {:token => 'public_tweet',
                       :name => "tweet", 
                       :private => false,
                       :position => 1},
                 1 => {:token => 'dm_tweet',
                       :name => "DM",
                       :private => true,
                       :position => 2}, 
                 2 => {:token => 'sms',
                       :name => "SMS",
                       :private => true,
                       :position => 3}, 
                 3 => {:token => 'email',
                       :name => "Email",
                       :private => true,
                       :position => 4},
                 4 => {:token => 'website',
                       :name => "Website",
                       :private => true,
                       :position => 5},
                 100 => {:token => 'best',
                         :name => "Best choice",
                         :private => nil,
                         :position => 0}}
  # Constants
  TWEET = 0
  TWEET_DM = 1
  SMS = 2
  EMAIL = 3
  WEBSITE = 4
  BEST = 100
  
  # Player message type
  MESSAGE_COMMUNICATION = 0
  MESSAGE_CHECKIN = 1
  MESSAGE_TYPE = {0 => MESSAGE_COMMUNICATION,
                  1 => MESSAGE_CHECKIN}
  
  def private?
    if self.delivered_via.present?
      DELIVER_VIA[self.delivered_via][:private]
    elsif self.deliver_via_pref.present?
      DELIVER_VIA[self.deliver_via_pref][:private]
    else
      return nil
    end
  end
  
  def deliver_via_name
    DELIVER_VIA[self.deliver_via_pref][:name]
  end

  def delivered_via_name
    DELIVER_VIA[self.delivered_via][:name]
  end
  
  def via_name
    if self.delivered
      self.delivered_via_name
    else 
      self.deliver_via_name
    end
  end
  def convert_links
    if !self.delivered?
      urls = LinkResource.convert_text_to_link_resources(self.content)
      self.content = LinkResource.convert_link_resources_to_notifications(self.content, urls, self.from_user, self.to_user, self.delivered_via, 'send_link_resource')  
    end
  end
  
  def deliver_message
    return if self.delivered? 
    @to_user = self.program_player.user

    
    # Don't deliver if they've got their notifications turned off
    if !@to_user.get_notifications?
      self.destroy
      return
    
    # Don't deliver this if this is an auto_message and the player is all caught up.
    # (Exception... if this is triggered by location)
    # Might want to turn this into a preference at some point.
    elsif self.auto_message.present? and 
      self.auto_message.deliver_trigger != AutoMessage::TRIGGER_TRAIT and 
      self.program_player.caught_up?
      
      self.destroy
      return
    
    # Don't deliver if they're not on the same level anymore
    elsif self.player_budge.present? and (self.player_budge.completed? or !self.player_budge.primary_program_budge?)
      self.destroy
      return
      
    # Don't deliver if the current budge is scheduled for the future
    elsif self.player_budge.present? and self.player_budge.program_player.present? and 
      self.player_budge.program_player.program_status == :scheduled
      
      self.destroy
      return
    
    end
    
    # Choose method of delivery
    case self.deliver_via_pref
      when BEST
        best_method = @to_user.pick_a_contact_method(desperation = 3)
        if best_method == :email
          self.delivered_via = EMAIL
        elsif best_method == :sms
          self.delivered_via = SMS
        elsif best_method == :public_tweet
          self.delivered_via = TWEET
        elsif best_method == :dm_tweet
          self.delivered_via = TWEET_DM
        else
          raise "unknown method: #{best_method}"
        end
      else
        self.delivered_via = self.deliver_via_pref
    end
    self.save 

    # Deliver 
    case self.delivered_via
      when EMAIL
        if @to_user.contact_them(:email, :player_message, self)    
          self.update_attributes({:delivered => true, :deliver_at => Time.now.utc})  
        end
      when SMS
        if @to_user.contact_them(:sms, :player_message, self)      
          self.update_attributes({:delivered => true, :deliver_at => Time.now.utc})  
        end
      when TWEET_DM
        if @to_user.contact_them(:dm_tweet, :player_message, self)
          self.update_attributes({:delivered => true, :deliver_at => Time.now.utc})  
        end
      when TWEET
        if @to_user.contact_them(:public_tweet, :player_message, self)
          self.update_attributes({:delivered => true, :deliver_at => Time.now.utc})  
        end
    end   
    
    self.update_delivered_stats if self.delivered?
    return true
  end
  
  def message_subject(via)
    case via
      when :email
        if self.subject.present?
          return self.subject
        else
          return "Play #{self.program.name}!"
        end
    else
      self.content
    end
  end
  
  def pre_message(via)
    if via == :email
      return "A little budge from the *#{self.program_player.program.name}* program:"
    else
      return nil
    end
  end
  
  def message_body(via)
    case via
      when :email
        return self.content
    else
      return nil
    end
  end
  
  # If there were any other links in the message, update those as delivered as well
  def update_delivered_stats
    self.player_message_resources.destroy_all
    self.content.scan(/#{DOMAIN}\/n\/(\w+)/).flatten.compact.each do |short_id|
      notification = Notification.find_by_short_id short_id
      next unless notification.for_object == 'send_link_resource'
      
      if notification.present? and !notification.delivered?
        to_user = self.program_player.user
        time_now = Time.now
        time_in_user_time_zone = time_now.in_time_zone(to_user.time_zone_or_default)
        notification.update_attributes({:delivered => true,
                                        :delivered_at => time_now.utc,
                                        :delivered_hour_of_day => time_in_user_time_zone.hour,
                                        :delivered_day_of_week => time_in_user_time_zone.wday,
                                        :delivered_week_of_year => time_in_user_time_zone.strftime('%W').to_i,
                                        :delivered_off_hours => to_user.is_off_hours?})          
      end
      PlayerMessageResource.create({:player_message_id => self.id,
                                    :link_resource_id => notification.for_id})
    end  
  end
    
  def update_program_player_message_counts
    if self.program_player.present?
      if self.to_coach?
        self.program_player.update_attributes({:num_messages_to_coach => PlayerMessage.where(:program_player_id => self.program_player_id, :to_coach => true).count})
      elsif self.from_coach?
        self.program_player.update_attributes({:num_messages_from_coach => PlayerMessage.where(:program_player_id => self.program_player_id, :from_coach => true).count})      
      end
    end
  end
  
  def program_name
    begin 
      Program.find(self.program_id).name
    rescue
      nil
    end
  end
  def level_number
    b=self.program_budge
    b.nil? ? nil : b.level
  end
  def to_twitter_username
    User.find(self.to_user_id).twitter_username
  end
  def notification
    Notification.where(:for_object => 'player_message', :for_id => self.id).first
  end
end

# == Schema Information
#
# Table name: player_messages
#
#  id                :integer(4)      not null, primary key
#  from_user_id      :integer(4)
#  from_remote_user  :string(255)
#  to_user_id        :integer(4)
#  to_remote_user    :string(255)
#  content           :text
#  program_player_id :integer(4)
#  player_budge_id   :integer(4)
#  remote_post_id    :string(255)
#  message_data      :text
#  delivered         :boolean(1)      default(FALSE)
#  deliver_at        :datetime
#  from_coach        :boolean(1)      default(FALSE)
#  to_coach          :boolean(1)      default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  program_id        :integer(4)
#  program_budge_id  :integer(4)
#  error             :string(255)
#  send_attempts     :integer(4)      default(0)
#  subject           :string(255)
#  auto_message_id   :integer(4)
#  delivered_via     :integer(4)      default(0)
#  deliver_via_pref  :integer(4)
#  trigger_trait_id  :integer(4)
#  entry_id          :integer(4)
#  to_player         :boolean(1)      default(FALSE)
#  to_supporters     :boolean(1)      default(FALSE)
#  checkin_id        :integer(4)
#  message_type      :integer(4)      default(0)
#

