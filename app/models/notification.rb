# == Schema Information
#
# Table name: notifications
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  short_id               :string(255)
#  delivered              :boolean(1)      default(FALSE)
#  delivered_at           :datetime
#  delivered_hour_of_day  :integer(4)
#  delivered_day_of_week  :integer(4)
#  delivered_week_of_year :integer(4)
#  responded_at           :datetime
#  responded_hour_of_day  :integer(4)
#  responded_day_of_week  :integer(4)
#  responded_week_of_year :integer(4)
#  delivered_via          :string(255)
#  message_style_token    :string(255)
#  message_data           :text
#  responded_minutes      :integer(4)
#  total_clicks           :integer(4)      default(0)
#  responded              :boolean(1)      default(FALSE)
#  completed_response     :boolean(1)      default(FALSE)
#  method_of_response     :integer(4)
#  shared_results         :boolean(1)      default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#  remote_user_id         :string(255)
#  remote_site_token      :string(255)
#  remote_post_id         :string(255)
#  delivered_immediately  :boolean(1)      default(FALSE)
#  num_signups            :integer(4)      default(0)
#  for_object             :string(255)
#  for_id                 :integer(4)
#  from_system            :boolean(1)      default(FALSE)
#  from_user_id           :integer(4)
#  delivered_off_hours    :boolean(1)      default(FALSE)
#  broadcast              :boolean(1)      default(FALSE)
#  ref_site               :string(255)
#  ref_url                :string(255)
#  expected_response      :boolean(1)      default(FALSE)
#

require 'base64'

class Notification < ActiveRecord::Base
  serialize :message_data
  belongs_to :user
  belongs_to :from_user, :class_name => 'User'
  after_create :set_creation_metadata

  def url
    "http://#{DOMAIN}/n/#{self.short_id}"
  end

  def set_creation_metadata
    self.update_attributes({:short_id => self.id.to_s(32)})    
  end    
  
  def data_object
    case self.for_object
      when 'send_link_resource'
        return LinkResource.find self.for_id
    end
  end
  
  # Deliver the message, with our without a user, with or without a notification object
  def self.deliver_message(via, message_data, user = nil, notification = nil)
    # If production, deliver via a number of methods
    if Rails.env.production? or (user and user.admin?)
      p "message data: #{message_data.inspect}"
      case via
        # Email
        when :email
          if user.present? or message_data[:to_email].present?
            message = Mailer.general_notice(user, message_data).deliver
            p "message: #{message.inspect}"
          else
            raise "Can't send email without a user or email address."
          end
          
        # SMS
        when :sms
          if message_data[:suppress_notification] and message_data[:subject].size > 160
            message_data[:subject] = "#{message_data[:subject][0..156]}..."
          elsif !message_data[:suppress_notification] and message_data[:subject].size > 140
            message_data[:subject] = "#{message_data[:subject][0..136]}..."
          end
          if user.present?
            TwilioApi.send_text(user.phone_normalized, "#{message_data[:subject]}#{message_data[:suppress_notification] ? '' : " #{message_data[:notification_url]}"}")                      
          elsif message_data[:to_phone].present?
            TwilioApi.send_text(message_data[:to_phone], "#{message_data[:subject]}#{message_data[:suppress_notification] ? '' : " #{message_data[:notification_url]}"}")            
          else
            raise "Can't send an sms without a user or phone number."
          end

        # Facebook: Not yet implemented
        when :facebook_wall
          Mailer.general_notice(user, message_data).deliver
          p "message (should've been to facebook): #{message.inspect}"

        # Tweet
        when :public_tweet
          p "sending tweet"
          consumer = OauthToken.get_consumer('twitter')
          access_token = OAuth::AccessToken.new(consumer, message_data[:from_oauth].token, message_data[:from_oauth].secret)
          
          if message_data[:to_oauth].present?
            tweet = "@#{message_data[:to_oauth].remote_username} #{message_data[:subject]}"        
          elsif message_data[:to_oauth_username]
            tweet = "@#{message_data[:to_oauth_username]} #{message_data[:subject]}"
          elsif user.present?
            tweet = "@#{user.twitter_username} #{message_data[:subject]}"        
          else
            tweet = message_data[:subject]        
          end
          if message_data[:suppress_notification] and tweet.size > 140
            tweet = "#{tweet[0..137]}..."
          elsif !message_data[:suppress_notification] and tweet.size > 119
            tweet = "#{tweet[0..116]}..."
          end
          
          response = access_token.post("/1/statuses/update.json",
                                       {:oauth_token => CGI::escape(message_data[:from_oauth].token),
                                        :trim_user => 1,
                                        :status => "#{tweet}#{message_data[:suppress_notification] ? '' : " #{message_data[:notification_url]}"}",
                                        :include_entities => 1}, 
                                       {'User-Agent'=>'Bud.ge'})
  
          parsed_response = JSON.parse(response.body) rescue nil
  
          # Update player_message.stats
          if message_data[:data_model] == :player_message  
            if parsed_response['id'].present? and parsed_response['created_at'].present?
              message_data[:data].update_attributes({:delivered => true,
                                      :remote_post_id => parsed_response['id'],
                                      :deliver_at => Time.parse(parsed_response['created_at']).utc,
                                      :message_data => parsed_response})                                  
              TrackedAction.add(:got_tweet_from_coach, message_data[:to_user])
            elsif parsed_response['error']
              message_data[:data].update_attributes({:error => parsed_response['error'],
                                                     :send_attempts => message_data[:data].send_attempts+1})
            end
          end

        # Direct Message via Twitter
        when :dm_tweet
          p "sending dm"
          if message_data[:to_oauth].present?
            remote_username = message_data[:to_oauth].remote_username
          elsif message_data[:to_oauth_username]
            remote_username = message_data[:to_oauth_username]        
          elsif user.present?
            remote_username = user.twitter_username        
          else
            raise "Can't send a DM without a twitter username."
          end
          
          dm = message_data[:subject]
          if message_data[:suppress_notification] and dm.size > 140
            dm = "#{dm[0..137]}..."
          elsif !message_data[:suppress_notification] and dm.size > 119
            dm = "#{dm[0..116]}..."
          end

          consumer = OauthToken.get_consumer('twitter')
          if message_data[:from_oauth].blank?
            message_data[:from_oauth] = OauthToken.budge_token('twitter')
          end
          access_token = OAuth::AccessToken.new(consumer, message_data[:from_oauth].token, message_data[:from_oauth].secret)
          response = access_token.post("/1/direct_messages/new.json",
                                       {:oauth_token => CGI::escape(message_data[:from_oauth].token),
                                        :user_id => (message_data[:to_oauth].present? ? 
                                                     message_data[:to_oauth].remote_user_id : 
                                                     nil),
                                        :screen_name => remote_username,
                                        :text => "#{dm}#{message_data[:suppress_notification] ? '' : " #{message_data[:notification_url]}"}"}, 
                                       {'User-Agent'=>'Bud.ge'})
  
          parsed_response = JSON.parse(response.body) rescue nil
          
          # Update player_message.stats
          if message_data[:data_model] == :player_message  
            if parsed_response['id'].present? and parsed_response['created_at'].present?
              message_data[:data].update_attributes({:delivered => true,
                                      :remote_post_id => parsed_response['id'],
                                      :deliver_at => Time.parse(parsed_response['created_at']).utc,
                                      :message_data => parsed_response})                                  
              TrackedAction.add(:got_dm_from_coach, message_data[:to_user])
            elsif parsed_response['error']
              if message_data[:data]
                message_data[:data].update_attributes({:error => parsed_response['error'],
                                                       :send_attempts => message_data[:data].send_attempts+1})
              end
            end
          end

        # Twilio call: not yet implemented
        when :robocall
          #Mailer.general_notice(self, message_data).deliver
      end

      if message_data[:notification].present? and !message_data[:suppress_notification]
        notification = message_data[:notification]
        time_now = Time.now
        if user
          time_in_user_time_zone = time_now.in_time_zone(user.time_zone_or_default)
        else
          time_in_user_time_zone = time_now.in_time_zone("Pacific Time (US & Canada)")        
        end
        # Mark this notification as delivered.
        notification.attributes = {:delivered => true,
                                   :delivered_at => time_now.utc,
                                   :delivered_hour_of_day => time_in_user_time_zone.hour,
                                   :delivered_day_of_week => time_in_user_time_zone.wday,
                                   :delivered_week_of_year => time_in_user_time_zone.strftime('%W').to_i,
                                   :delivered_immediately => true,
                                   :delivered_off_hours => (user.present? ? user.is_off_hours? : false)}
        notification.save
      end        
      return true
      
    # If development, deliver via email only
    else
      
      # Send it to them, if they have an account
      if via == :sms and user and user.in_beta?
        message_data[:diverted_from_method] = via unless via == :sms
        TwilioApi.send_text(user.phone, "#{message_data[:subject]} #{message_data[:notification_url]}")        
      elsif user
        message_data[:diverted_from_method] = via unless via == :email
        Mailer.general_notice(user, message_data).deliver
      end
      
      if message_data[:notification].present?
        notification = message_data[:notification]
        time_now = Time.now
        time_in_user_time_zone = time_now.in_time_zone("Pacific Time (US & Canada)")
        
        # Mark this notification as delivered.
        notification.attributes = {:delivered => true,
                                   :delivered_at => time_now.utc,
                                   :delivered_hour_of_day => time_in_user_time_zone.hour,
                                   :delivered_day_of_week => time_in_user_time_zone.wday,
                                   :delivered_week_of_year => time_in_user_time_zone.strftime('%W').to_i,
                                   :delivered_immediately => true,
                                   :delivered_off_hours => (user.present? ? user.is_off_hours? : false)}
        notification.save
      end  
      return true  
    end  
  end
  
  def self.get_global_weights
    return @global_weights if @global_weights.present?
    # Global weights by :hour and :hour_and_day
    @global_weights = {:hour => Hash.new(0), :day_and_hour => Hash.new}
    VisitStat.find(:all, :conditions => ['constrained_by IN (?)', ['global_hour', 'global_day_and_hour']]).each do |visit_stat|
      if visit_stat.constrained_by == 'global_hour'
        @global_weights[:hour][visit_stat.constrained_by_id1.to_i] = visit_stat.percent_visits
        
      elsif visit_stat.constrained_by == 'global_day_and_hour'
        @global_weights[:day_and_hour][visit_stat.constrained_by_id1.to_i] ||= Hash.new(0)
        @global_weights[:day_and_hour][visit_stat.constrained_by_id1.to_i][visit_stat.constrained_by_id2.to_i] = visit_stat.percent_visits
      
      end
    end
    return @global_weights    
  end    

  def self.get_user_weights(user, constrained_by)
    # Global weights by :hour and :hour_and_day
    user_weights = {:hour => Hash.new(0), :day_and_hour => Hash.new}
    VisitStat.find(:all, :conditions => ['constrained_by_id1 = ? AND constrained_by = ?', user.id.to_s, constrained_by.to_s]).each do |visit_stat|
      if constrained_by == 'user_hour'
        user_weights[:hour][visit_stat.constrained_by_id2.to_i] = visit_stat.percent_visits
        
      elsif constrained_by == 'user_day_and_hour'
        user_weights[:day_and_hour][visit_stat.constrained_by_id2.to_i] ||= Hash.new(0.0)
        user_weights[:day_and_hour][visit_stat.constrained_by_id2.to_i][visit_stat.constrained_by_id3.to_i] = visit_stat.percent_visits
      
      end
    end
    return user_weights    
  end     

  #what is the content of the message that got sent (the table has many different types of messages so this isn't straightforward)
  def get_message
    msg=nil
    return nil unless self.message_data.present? #and self.message_data.class == Hash
    return self.message_data[:testimonial] if self.message_data[:testimonial].present?
    
    msg_data = self.message_data[:data]
    return unless msg_data.class == Hash
    if msg_data[:message].present?
      msg_data[:message]
    elsif msg_data[:content].present?
      msg_data[:content]
    elsif msg_data[:name].present?
      "Program: #{msg_data[:name]}"
    elsif msg_data[:url_title].present?
      "msg_data[:url_title]: msg_data[:url]"
    else
      # self.to_yaml          
    end
  end



end

  

# Buster deleted Notification.generate_next_notification_dates on 9/27/2011
# Buster deleted Notification.daily_budge on 9/27/2011
