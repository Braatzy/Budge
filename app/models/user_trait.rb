# == Schema Information
#
# Table name: user_traits
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)      not null
#  trait_id          :integer(4)      not null
#  level             :integer(4)      default(0)
#  created_at        :datetime
#  updated_at        :datetime
#

class UserTrait < ActiveRecord::Base
  belongs_to :user
  belongs_to :trait
  has_many :user_actions, :dependent => :destroy
  has_many :checkins
  
  def summary_results(date = Date.today, last_x_days = 30)
    return @statement if @statement
    checkins = Checkin.where(:user_id => self.user_id, :trait_id => self.trait_id).where('date(checkin_datetime) <= ? AND date(checkin_datetime) >= ?', date+1.day, date-last_x_days.days)
    num_results = checkins.size
    return Hash.new(0) unless num_results > 0
    total_decimal = checkins.inject(0){|sum, checkin|sum+checkin.amount_decimal}
    if total_decimal.to_i == total_decimal
      total_decimal = total_decimal.to_i
    else
      total_decimal = (total_decimal*100).to_i/100.0
    end
    average = total_decimal/num_results
    if average != average.to_i
      average = (average * 100).to_i/100.0
    end
    
    return {:total => total_decimal, :num_results => num_results, :average => average}
  end

  # Update all active user_actions for this user_trait across programs...
  # This method adds the following items to checkin_hash
  # | user_action_id               | int(11)       | YES  |     | NULL    |                | 
  # | player_budge_id              | int(11)       | YES  |     | NULL    |                | 
  # | did_action                   | tinyint(1)    | YES  |     | 0       |                | 
  # | desired_outcome              | tinyint(1)    | YES  |     | 1       |                | 
  def save_new_data(checkin_hash, options_hash = Hash.new)
      
    # Find any old user actions that need reviving, and revive them.
    if checkin_hash[:checkin_via] != 'player'
      old_time_zone = Time.zone
      Time.zone = self.user.time_zone_or_default
      self.user_actions.where(:status => UserAction::STARTED).select{|ua|ua.needs_reviving?}.each do |user_action|
        user_action.player_budge.move_to_day(1, Time.zone.today)
      end
      Time.zone = old_time_zone
    end

    # Get all user_actions related to this trait, update all of them
    user_actions = self.user_actions.where(:status => UserAction::STARTED)
    
    user_actions = user_actions.select{|ua|ua.in_progress?} if user_actions.present?
    trait = self.trait
    logger.warn "#{user_actions.size} user actions: #{checkin_hash.inspect}"

    checkins = []
    if user_actions.present?
      player_budge_updated = Hash.new
      num_saved_checkins = 0
      user_actions.sort_by{|u|u.sort_by}.each_with_index do |user_action, index|
      
        # Only save this checkin one time per player_budge (for examples like in pushups where multiple actions exist with same trait)
        if player_budge_updated[user_action.player_budge_id].present?
          next
        elsif user_action.day_number != user_action.player_budge.day_of_budge
          next
        else
          player_budge_updated[user_action.player_budge_id] = true
        end
        
        # Mark all but 1 as a duplicate
        if num_saved_checkins == 0
          checkin_hash[:duplicate] = false
        else
          checkin_hash[:duplicate] = true
        end
      
        # Attach the user action to the checkin
        checkin_hash[:user_action_id] = user_action.id
        checkin_hash[:user_id] ||= user_action.user_id
        checkin_hash[:player_budge_id] = user_action.player_budge_id
        checkin_hash[:trait_id] ||= user_action.trait_id
        if checkin_hash[:player_budge_id].present?
          program_player = ProgramPlayer.where(:player_budge_id => user_action.player_budge_id).first
          checkin_hash[:program_player_id] = program_player.id
        end      
        # Whether or not they are reporting an action actually happening (versus not happening)
        checkin_hash[:did_action] = false
        if trait.answer_type == ':boolean' 
          if checkin_hash[:amount_decimal] > 0
            checkin_hash[:did_action] = true
          end
        else
          if checkin_hash[:amount_decimal].present?
            if checkin_hash[:amount_decimal].to_f > 0 or !trait.zero_equals_no_action?      
              checkin_hash[:did_action] = true
            end
          end
        end

        # Determine desired_outcome
        if user_action.do? and checkin_hash[:did_action] == true
          checkin_hash[:desired_outcome] = true
        elsif user_action.dont? and checkin_hash[:did_action] == false
          checkin_hash[:desired_outcome] = true       
        else
          checkin_hash[:desired_outcome] = false 
        end
        
        # Checkin.attributes, user_trait, user_action, options_hash
        @checkin = Checkin.save_new_checkin(checkin_hash, self, user_action, options_hash)      
        checkins << @checkin
                
        num_saved_checkins += 1
      end

    # Check in without a program
    # Trait.find_by_token('situps').save_checkins_for_user(User.find(41), {:raw_text => "I did 10 situps", :amount_decimal => 10, :checkin_via => 'sms'})
    # Trait.find_by_token('share_meal').save_checkins_for_user(User.find(41), {:raw_text => "I ate a burrito", :amount_text => "I ate a burrito", :amount_decimal => 1, :checkin_via => 'sms'})
    else    

      # Checkin.attributes, user_trait, user_action, options_hash
      @checkin = Checkin.save_new_checkin(checkin_hash, self, nil, options_hash)

      # Create generic stream item
      if @checkin.present? and (@checkin.checkin_via == 'sms' or 
                                @checkin.checkin_via == 'twitter' or @checkin.checkin_via == 'twitter_dm')
        @entry_attributes = {:user_id => @checkin.user_id,
                             :program_id => nil,
                             :program_player_id => nil,
                             :program_budge_id => nil,
                             :player_budge_id => nil,
                             :parent_id => nil,
                             :location_context_id => nil,
                             :privacy_setting => Entry::PRIVACY_PUBLIC,
                             :message => nil,
                             :message_type => 'programless_checkin',
                             :checkin_id => @checkin.id,
                             :original_message => @checkin.raw_text,
                             :date => Time.zone.today.to_date,
                             :post_to_coach => true,
                             :post_to_twitter => false,
                             :post_to_facebook => false}
  
        @existing_entry = Entry.find_by_message_type_and_checkin_id('programless_checkin', @checkin.id)
        if @existing_entry.present?
          @existing_entry.update_attributes(@entry_attributes)        
        else
          @entry = Entry.create(@entry_attributes)
        end
      end
      
      checkins << @checkin
    end
    return checkins
  end
    
  def recent_actions(in_past_days=30)
    self.user_actions.find(:all, :conditions => ["created_at >= ?", Time.now.in_time_zone(self.user.time_zone_or_default) - in_past_days.day])
  end  
end