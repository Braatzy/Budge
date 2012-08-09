class AutoMessage < ActiveRecord::Base
  belongs_to :program
  belongs_to :program_budge
  belongs_to :user # Person who created this prompt initially
  belongs_to :trigger_trait, :class_name => 'Trait'
  acts_as_list :scope => :program_budge
  
  AUTO_MESSAGE_TYPES = {0 => {:name => "Active player",
                              :menu_name => "Active player",
                              :send_timing => "when triggered"},
                        10 => {:name => "Lapsed player (3 days)",
                              :menu_name => "Lapsed player (3 days)",
                              :send_timing => "when player hasn't visited in 3 days"}
                       }
  AUTO_MESSAGE_TYPE_ACTIVE = 0
  AUTO_MESSAGE_TYPE_LAPSED = 10
  
  STATUS = {0 => 'draft',
            1 => 'live',
            2 => 'retired'}
  PUBLISH_STATUS_DRAFT = 0
  PUBLISH_STATUS_LIVE = 1
  PUBLISH_STATUS_RETIRED = 2

  # Defined in PlayerMessage
  DELIVER_VIA = PlayerMessage::DELIVER_VIA # 0 = Twitter, 1 = DM, etc...
            
  DELIVERY_WINDOW = {0 => {:menu_name => 'on the nose'},
                     3 => {:menu_name => 'or best within following 3 hours'},
                     6 => {:menu_name => 'or best within following 6 hours'},
                     12 => {:menu_name => 'or best within following 12 hours'},
                     24 => {:menu_name => 'or best within following 24 hours'},
                     72 => {:menu_name => 'or best within following 3 days'},
                     168 => {:menu_name => 'or best within following week'}}
    
  DELIVERY_TRIGGER = {0 => 'hour_and_day_number',
                      1 => 'hour_and_day_of_week',
                      2 => 'trait_checkin',
                      3 => 'temperature',
                      4 => 'weather_conditions'}
  TRIGGER_DAY_NUMBER = 0
  TRIGGER_DAY_OF_WEEK = 1
  TRIGGER_TRAIT = 2
  
  DAY_OF_WEEK_TO_DAY = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                
  def private?
    if self.deliver_via == 1 or self.deliver_via == 2 or self.deliver_via == 3
      return true
    else
      return false
    end
  end  
  def human_hour
    return '' unless self.hour.present?
    text = "#{(self.hour < 13 ? self.hour : (self.hour-12))}#{(self.hour < 12 ? 'am' : 'pm')}"
  end    
  def status_live?
    self.status == 1
  end
  def timed?
    self.deliver_trigger == TRIGGER_DAY_NUMBER or self.deliver_trigger == TRIGGER_DAY_OF_WEEK
  end
  def send_timing
    AUTO_MESSAGE_TYPES[self.auto_message_type][:send_timing] rescue "invalid auto message type"
  end
  def status_name
    STATUS[self.status].capitalize
  end
  def auto_message_type_name
    AUTO_MESSAGE_TYPES[self.auto_message_type][:name] rescue 'Deprecated'
  end
  def deliver_via_name
    DELIVER_VIA[self.deliver_via][:name]
  end
  def delivery_window_name
    DELIVERY_WINDOW[self.delivery_window][:menu_name]
  end
  def content_formatted?
    self.deliver_via == 3
  end
  
  def sort_by
    [self.day_number.to_i, self.hour.to_i, self.created_at]  
  end
  
  def self.options_for_auto_message_types
    AUTO_MESSAGE_TYPES.sort.map{|id, details|[details[:menu_name], id]}
  end

  def self.options_for_status
    STATUS.sort.map{|id, value|[value, id]}
  end

  def self.options_for_deliver_via
    DELIVER_VIA.sort_by{|id, details|details[:position]}.map{|id, details|[details[:name], id]}
  end

  def self.options_for_delivery_window
    DELIVERY_WINDOW.sort.map{|id, details|[details[:menu_name], id]}
  end

  # Can take a hardcoded hour or :best as the time
  def determine_best_delivery_time(time, program_player, player_budge)
    days_late = player_budge.days_late
    days_late = 0 if days_late < 0 # If it's scheduled for the future, for instance
    begin_window = player_budge.day_starts_at + days_late.days
    
    # Choose a random hour between auto_message.hour and auto_message.delivery_window
    if time == :best
      start_window = begin_window + self.hour.hours
      end_window = start_window + self.delivery_window.hours
  
      times = Array.new
      while (start_window <= end_window) 
        times << start_window
        start_window += 1.hour
      end

      return times[rand(times.size)]
      
    # Go with their hard-coded time
    else
      return begin_window + time.hours
    end    
  end

  # time can equal an hour integer, or :best
  # {:time => (:best, or hour in),
  #  :program_player => ,
  #  :player_budge => }
  def schedule_for_player_budge(options = {})
    time           = options[:time].present? ? options[:time] : nil
    program_player = options[:program_player].present? ? options[:program_player] : raise("missing program player")
    player_budge   = options[:player_budge].present? ? options[:player_budge] : raise("missing player budge")
    
    # Return unless this budge is actually in play, and we're on a day on or after the current day for this person's budge
    return nil if player_budge.completed? 

    # Only need to schedule daily_budges at this point
    return nil unless self.auto_message_type == AUTO_MESSAGE_TYPE_ACTIVE and 
                      self.status == PUBLISH_STATUS_LIVE
    
    @user = program_player.user
    
    # Turn all of the link_resource stub urls into notifications
    @text = LinkResource.convert_auto_message_into_player_message_text(self, player_budge)
    
    # If this message should be delivered at a specific day and time
    if self.timed?
      @deliver_at = self.determine_best_delivery_time(time, program_player, player_budge)
      
      # Don't schedule auto_messages from the past if this is a restarted budge
      return nil if @deliver_at.nil? or @deliver_at.utc < (Time.now.utc - 1.hour)
      
    # If this should only be delivered when the some auto-checkin to a specific trait happens
    elsif self.deliver_trigger == TRIGGER_TRAIT
      @trigger_trait_id = self.trigger_trait_id
    end

    @player_message = PlayerMessage.create({:auto_message_id => self.id,
                                            :to_user_id => @user.id,
                                            :to_remote_user => nil,
                                            :content => @text,
                                            :program_id => player_budge.program_player.program_id,
                                            :program_player_id => player_budge.program_player.id,
                                            :program_budge_id => (player_budge.present? ? player_budge.program_budge_id : nil),
                                            :player_budge_id => player_budge.id,
                                            :deliver_via_pref => self.deliver_via,
                                            :deliver_at => (@deliver_at.present? ? @deliver_at.utc : nil),
                                            :trigger_trait_id => @trigger_trait_id,
                                            :delivered => false,
                                            :to_player => true})

    return @player_message
  end
end

# == Schema Information
#
# Table name: auto_messages
#
#  id                :integer(4)      not null, primary key
#  auto_message_type :integer(4)      default(0)
#  program_id        :integer(4)
#  program_budge_id  :integer(4)
#  position          :integer(4)      default(1000)
#  user_id           :integer(4)
#  status            :integer(4)      default(0)
#  subject           :string(255)
#  content           :text
#  delivery_window   :integer(4)      default(0)
#  deliver_trigger   :integer(4)      default(0)
#  day_number        :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  hour              :integer(4)
#  include_link      :boolean(1)      default(TRUE)
#  deliver_via       :integer(4)      default(0)
#  trigger_trait_id  :integer(4)
#  active            :boolean(1)      default(TRUE)
#

