require "linguistics"

class Checkin < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_action
  belongs_to :trait
  belongs_to :user_trait
  belongs_to :player_budge
  belongs_to :program_player
  has_many :player_messages, :dependent => :destroy # Little note about them checking in
  has_one :entry # when the checkin is done outside of a program
  
  before_save :time_metadata
  after_save :schedule_next_action_if_complete, :update_coach_stream
  
  
  scope :since, lambda {|timestamp| {:conditions => {:created_at => (timestamp .. Time.now.utc)}}}
  
  # (verb) (quantity) (unity)
  # read a book
  # read 3 books
  # didn't read a book
  # Trait.statement(current_user, :past, checkin.trait, checkin.amount_decimal, checkin, prefer_details = true)
  
  def statement(tense = :past)
    return @statement if @statement.present?
    return "trait info missing" unless self.trait.present? and self.trait.verb.present?
    
    @statement = Trait.statement(self.user, tense, self.trait, self.amount_decimal, self, prefer_details = true)
    return @statement
  end

  def summary_results(date = Date.today, last_x_days = 30)
    self.user_trait.summary_results(date, last_x_days)
  end

  # ONLY NEW ITEM NEEDED: | amount_units                 | varchar(255)  | YES  |     | NULL    |                | 
  def self.save_new_checkin(checkin_hash, user_trait, user_action = nil, options_hash = Hash.new)
    checkin_datetime = (checkin_hash[:checkin_datetime] ? checkin_hash[:checkin_datetime] : Time.zone.now.in_time_zone(user_trait.user.time_zone_or_default))
    p "checkin_datetime: #{checkin_datetime}"
    
    # If this is for a date that comes before or after this particular user_action, ignore it.
    if user_action.present? and checkin_hash[:date].present? and (user_action.player_budge.start_date > Date.parse(checkin_hash[:date].to_s) or !user_action.in_progress?)
      checkin_hash[:user_action_id] = nil
      user_action = nil
    end
    
    # If this is a checkin imported from an external API, look for dupes
    if checkin_hash[:remote_id].present? and checkin_hash[:checkin_via].present?
      @checkin = Checkin.where(:checkin_via => checkin_hash[:checkin_via],
                               :remote_id => checkin_hash[:remote_id],
                               :user_id => user_trait.user.id).first
      if @checkin.present?
        return nil
      end
    # Not from a remote api?    
    else
      @checkin = Checkin.where(:user_trait_id => user_trait.id,
                               :user_action_id => (user_action.present? ? user_action.id : nil),
                               :date => checkin_hash[:date]).first
    
    end
    
    if @checkin.present?
      # If this is for something that accumulates, add it to the total...
      if !@checkin.new_record? and @checkin.trait.present? and @checkin.trait.cumulative_results?
        checkin_hash[:amount_decimal] ||= 0
        checkin_hash[:amount_decimal] = checkin_hash[:amount_decimal].to_f
        checkin_hash[:amount_decimal] += @checkin.amount_decimal.to_f
      end
      @checkin.update_attributes(checkin_hash)
    else
      @checkin = Checkin.new(checkin_hash)
      @checkin.attributes = {:amount_units => UserAction.amount_units(user_trait.user, user_trait.trait.answer_type), 
                             :checkin_datetime => checkin_datetime,
                             :checkin_datetime_approximate => false}
      if @checkin.save
        logger.warn "SAVED: #{@checkin.id}"

        # Check for location-based reminders for this checkin
        if !@checkin.duplicate? and @checkin.checkin_via != 'player' 
          if Rails.env.production?
            @checkin.delay.check_triggered_player_messages          
          else
            @checkin.check_triggered_player_messages
          end
        end
        
        # Check to see if this auto-checkin has auto-completed the budge
        if @checkin.checkin_via != 'player' and @checkin.player_budge.present?
          @checkin.player_budge.save_days_checkin({:date => @checkin.date, :notify => true})
        end

      else
        logger.warn "NOT SAVED: #{@checkin.errors.inspect}"
      end
    end                
    return @checkin    
  end

  def check_triggered_player_messages
    player_messages_by_trait = PlayerMessage.where(:to_user_id => self.user_id, 
                                                   :delivered => false, 
                                                   :trigger_trait_id => self.trait_id).order(:id)

    # Deliver the first player message that is part of a budge in progress
    if player_messages_by_trait.present? 
      player_messages_by_trait.each do |player_message|
        if player_message.player_budge.present? and player_message.player_budge.in_progress?
          return player_message.deliver_message
        end
      end
    
    # Don't contact about backfilled data
    elsif self.date >= Time.zone.today-1.day
      if self.checkin_via == 'foursquare'
        return true # no need to notify
      else
        return self.user.contact_them(:sms, :auto_checkin_received, self)
      end
   else
      return true
    end
  end
  
  VALID_VERBS = {'share' => true,
                 'do' => true,
                 'walk' => true,
                 'drink' => true,
                 'floss' => true,
                 'meditate' => true,
                 'run' => true,
                 'eat' => true,
                 'pullup' => true,
                 'pushup' => true,
                 'situp' => true,
                 'weigh in' => true}
  
  def self.parse_text_checkin(text)
    return nil unless text.present?
    verb_hash = Trait.string_to_verb_hash
    answer_type_hash = Trait.string_to_answer_type_hash
    strings = text.split('. ')
    results = Array.new
    
    # In case they are checking in with several statements
    # v = verb, q = quantity, u = units
    strings.each do |string|

      # Try to pull out information from the string
      string.chomp!
      string.gsub!(/( for | to | at |, )/,' ')
      match_method = nil

      # I did 10 pullups
      # I did 10 situps
      # I did plank for 10 minutes (no)
      # I planked for 3 minutes (no)
      # I did 10 minues of plank (yes, but not correctly)
      # Walked 5 steps
      if string.match(/I?\s?(\w+) ([\d\.\,]+)\s?(\w+)?/i) 
        v, q, u = $1, $2, $3
        match_method = 1

      # I did a pushup
      # I drank a drink
      elsif string.match(/I?\s?(\w+) (a |an |the |it |some )\s?(\w+)?/i) 
        v, q, u = $1, 1, $3    
        match_method = 2

      # I did zero pushups
      elsif string.match(/I?\s?(\w+) (no |zero )\s?(\w+)?/i)
        v, q, u = $1, 0, $3    
        match_method = 3

      # 10 pushups
      # 10 minutes meditation
      elsif string.match(/([\d\.\,]+)\s(\w+)\s?(\w+)?/i) 
        v, q, u = ($3 || 'did'), $1, $2
        match_method = 4

      # I flossed
      # Flossed
      elsif string.match(/I?\s?(\w+)/i) 
        v, q, u = $1, 1, nil
        match_method = 5

      # I had a shot
      elsif string.match(/I?\s?(\w+) (\w+)/i) 
        v, q, u = $1, 1, $2  
        match_method = 6

      elsif string.match(/I?\s?(\w+)/i)
        v, q, u = $1, 1, ''  
        match_method = 7
      end
      if v.present?
        string.match("#{v}\s+(.*)")
        rest_of_string = $1
      end
      p "(match method #{match_method}): v = #{v}, q = #{q}, u = #{u} = #{v.present? ? verb_hash[v.downcase] : nil}"
      u ||= '' # so pluralization and downcasing don't error out

      # Sometimes verb and noun are flipped
      if v.present? and !verb_hash[v.downcase].present? 
        # 10 minutes plank
        if verb_is_noun = Trait.where(:noun => v.downcase).first
          p "flipping verb and noun"
          u = v.downcase
          v = verb_is_noun.verb

        end
        p "(match flip): v = #{v}, q = #{q}, u = #{u} = #{verb_hash[v.downcase]}"
      end

      if v.present? and verb_hash[v.downcase].present?  
        checkin_trait = Trait.verb_to_checkin_trait(verb_hash[v.downcase])
        p "hard-coded checkin_trait: #{checkin_trait.inspect}"

        # Specialized to work for sharing what you ate.. will need to refactored once more traits use this
        if checkin_trait.present?
          if checkin_trait.answer_type == ':text'
            result = {:trait => checkin_trait,
                      :text => rest_of_string,
                      :verb_original => v,
                      :verb => verb_hash[v.downcase],
                      :quantity => 1,
                      :noun => u,
                      :noun_alt => u.en.plural}
          # Not tested yet...
          else
            result = {:trait => checkin_trait,
                      :verb_original => v,
                      :verb => verb_hash[v.downcase],
                      :quantity => q,
                      :noun => u,
                      :noun_alt => u.en.plural}          
          end
        else
          trait_matches = Array.new
          
          trait_matches << Trait.where(:verb => verb_hash[v.downcase]).where('noun = ? OR noun = ?', u, u.en.plural)
          # If we're looking for matches on verb and answer_type   
          if trait_matches.flatten.blank?
            if answer_type_hash[u.downcase].present?
              trait_matches << Trait.where(:verb => verb_hash[v.downcase], :answer_type => answer_type_hash[u.downcase])
              trait_matches << Trait.where(:noun => verb_hash[v.downcase], :answer_type => answer_type_hash[u.downcase])
            elsif answer_type_hash[u.en.plural.downcase].present?
              trait_matches << Trait.where(:verb => verb_hash[v.downcase], :answer_type => answer_type_hash[u.en.plural.downcase])
              trait_matches << Trait.where(:noun => verb_hash[v.downcase], :answer_type => answer_type_hash[u.en.plural.downcase])
            elsif answer_type_hash[u.en.plural.downcase].present?
              trait_matches << Trait.where(:verb => verb_hash[v.downcase], :answer_type => answer_type_hash[u.en.plural.downcase])
            else
              trait_matches << Trait.where(:verb => verb_hash[v.downcase])
            end
          end

          fuzzy_matches = Trait.where('verb like ?', "%#{verb_hash[v.downcase]}%").where('noun like ? OR noun like ?', "%#{u}%", "%#{u.en.plural}%")          
          trait_matches = trait_matches.flatten.select{|e|e.present?}.uniq
          fuzzy_matches = fuzzy_matches.flatten.select{|e|e.present?}.uniq - trait_matches

          #p "#{trait_matches.size} final trait_matches: #{trait_matches.inspect}"
          #p "#{fuzzy_matches.size} final fuzzy_matches: #{fuzzy_matches.inspect}"
          
          # If the fuzzy matches has fewer results than the specific matches, assume it's because we found something that's a better match (especially for verbs that are 2 words)
          if fuzzy_matches.present? and fuzzy_matches.size < trait_matches.size
            trait_matches = fuzzy_matches
            fuzzy_matches = []
          end
          
          #p "trait: #{((trait_matches.present? and trait_matches.size == 1) ? trait_matches.first : nil).inspect}"
          result = {:trait => ((trait_matches.present? and trait_matches.size == 1) ? trait_matches.first : nil),
                    :traits_matching => trait_matches,
                    :fuzzy_matches => fuzzy_matches,
                    :verb_original => v,
                    :verb => verb_hash[v.downcase],
                    :quantity => q,
                    :noun => u,
                    :noun_alt => u.en.plural}
        end
        
        # Only allow valid verbs to be parsed
        if result.present? and result[:trait].present? and VALID_VERBS[result[:trait].verb].present?
          results << result
        end
      end
    end
    return results
  end
  
  def get_metadata_summary
    summary_results = self.summary_results
    if !self.trait.cumulative_results? and summary_results[:total] > 1
      percentage_change = ((self.amount_decimal-summary_results[:average])*100)/self.amount_decimal
    end
    summary_statement = Trait.statement(self.user, :past, self.trait, summary_results[:total], nil, false)
    return {:trait_id => self.trait_id,
            :user_trait_id => self.user_trait_id,
            :user_action_id => self.user_action_id,
            :statement => self.statement(:past),
            :summary_statement => summary_statement,
            :summary_num_results => summary_results[:num_results],
            :summary_total => summary_results[:total],
            :summary_average => summary_results[:average],
            :percentage_change => percentage_change,
            :answer_type => self.trait.answer_type} 
  end
  
  def self.unique_checkin_hash(checkin_array, date, last_x_days)
    checkins = checkin_array.select('distinct(date)').where("date > ? AND date <= ?", date-last_x_days.days, date).sort_by{|c|c.date}
    date_hash = Hash.new
    checkins.each do |checkin|
      date_hash[checkin.date] = true
    end
    checkin_string = ''
    (0..last_x_days-1).each do |days_ago|
      if date_hash[date-days_ago.days].present?
        checkin_string += '1'
      else
        checkin_string += '0'
      end
    end
    return {:string => checkin_string, :num_unique_dates => checkins.size}  
  end

  # Dupe of what's in ProgramPlayer 
  def unique_checkin_dates(date = Date.today, last_x_days = 30)
    return Checkin.unique_checkin_hash(self.user_trait.checkins, date, last_x_days)
  end
    
  def schedule_next_action_if_complete
    # Score this player_budge if this checkin completed it

    # Score and schedule this user_action if this checkin completed it
    self.user_action.schedule_next_day_or_budge(self) if self.user_action.present?

    # Score and schedule this player_budge if this checkin completed all the user_actions
    self.player_budge.check_and_complete_if_done(self.date, notify = false) if self.player_budge.present?
  end  
  
  def update_coach_stream
    player_budge = self.player_budge
    if player_budge.present?
      return unless player_budge.program_player.present?
      player_message = PlayerMessage.find_or_initialize_by_checkin_id({:checkin_id => self.id})
      player_message.attributes = {:content => "#{self.statement(:past)}",
                                   :from_user_id => self.user.id,
                                   :message_type => PlayerMessage::MESSAGE_CHECKIN,
                                   :program_id => player_budge.program_player.program_id,
                                   :program_player_id => player_budge.program_player_id,
                                   :player_budge_id => player_budge.id,
                                   :program_budge_id => player_budge.program_budge_id,
                                   :delivered => true,
                                   :delivered_via => PlayerMessage::WEBSITE,
                                   :deliver_at => Time.now.utc}
      player_message.save
    end
  end
    
  # | end_clock_remaining          | int(11)       | YES  |     | NULL    |                | 
  # | hour_of_day                  | int(11)       | YES  |     | NULL    |                | 
  # | day_of_week                  | int(11)       | YES  |     | NULL    |                | 
  # | week_of_year                 | int(11)       | YES  |     | NULL    |                | 
  def time_metadata
    if self.checkin_datetime.present? and self.hour_of_day.blank?
      time_in_time_zone = Time.parse(self.checkin_datetime.to_s).in_time_zone(self.user.time_zone_or_default)

      # remining_time based on a 24 hour clock (can be negative if they took longer than a day to do this)
      if self.player_budge.present? and self.player_budge.day_starts_at.present?
        remaining_time = ((self.player_budge.day_starts_at+1.day - time_in_time_zone)/60.0).round
      end

      self.attributes = {:hour_of_day => time_in_time_zone.hour,
                         :day_of_week => time_in_time_zone.wday,
                         :week_of_year => time_in_time_zone.strftime('%W').to_i,
                         :end_clock_remaining => remaining_time}
    end
  end
  
  def level_number
    self.player_budge.level_number
  end
end

# Deleted on 9/27/2011 by Buster
# creating UserComment for each Checkin, to be attached to the UserAction
# find, create, delete related_comment for this checkin.

# == Schema Information
#
# Table name: checkins
#
#  id                           :integer(4)      not null, primary key
#  user_id                      :integer(4)
#  is_player                    :boolean(1)      default(TRUE)
#  user_action_id               :integer(4)
#  trait_id                     :integer(4)      not null
#  latitude                     :decimal(15, 10)
#  longitude                    :decimal(15, 10)
#  did_action                   :boolean(1)      default(FALSE)
#  desired_outcome              :boolean(1)      default(TRUE)
#  comment                      :text
#  amount_integer               :integer(4)      default(0)
#  amount_decimal               :decimal(10, 2)
#  amount_string                :string(255)
#  amount_text                  :text
#  checkin_datetime             :datetime
#  checkin_datetime_approximate :boolean(1)      default(FALSE)
#  hour_of_day                  :integer(4)
#  day_of_week                  :integer(4)
#  week_of_year                 :integer(4)
#  checkin_via                  :string(255)
#  end_clock_remaining          :integer(4)
#  created_at                   :datetime
#  updated_at                   :datetime
#  player_leveled_up            :boolean(1)      default(FALSE)
#  coach_leveled_up             :boolean(1)      default(FALSE)
#  amount_units                 :string(255)
#  user_trait_id                :integer(4)      not null
#  date                         :date
#  remote_id                    :string(255)
#  stars_for_participation      :decimal(11, 10) default(0.0)
#  stars_for_mastery            :decimal(11, 10) default(0.0)
#  stars_for_commenting         :decimal(11, 10) default(0.0)
#  stars_total                  :decimal(11, 10) default(0.0)
#  player_budge_id              :integer(4)
#  duplicate                    :boolean(1)      default(FALSE)
#  program_player_id            :integer(4)
#  raw_text                     :text
#

