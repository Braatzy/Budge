class UserAction < ActiveRecord::Base
  before_destroy :destroy_related_stuff
  
  belongs_to :user
  belongs_to :player, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :coach, :class_name => 'User', :foreign_key => 'coach_user_id'
  belongs_to :trait
  belongs_to :user_trait
  belongs_to :program
  belongs_to :program_budge
  belongs_to :player_budge
  belongs_to :program_action_template
  has_many :user_comments, :foreign_key => 'related_id', :conditions => ['related_type = ?', 'user_action']
  has_many :user_likes, :foreign_key => 'related_id', :conditions => ['related_type = ?', 'user_action']
  has_many :checkins
  
  # completion_requirement_number is needed per this period
  STATUS = {0 => :added, 1 => :started, 2 => :skipped, 3 => :ended_early, 4 => :completed, 5 => :victorious, 6 => :expired}
  ADDED = 0
  STARTED = 1
  SKIPPED = 2
  ENDED_EARLY = 3
  COMPLETED = 4
  VICTORIOUS = 5
  EXPIRED = 6
    
  def sort_by
    if self.program_action_template.present?
      return [self.player_budge_id, self.day_number, self.program_action_template.position, self.id]
    else
      return [self.player_budge_id, self.day_number,1000]
    end
  end
  
  def action_wording
    if self.program_action_template.present?
      self.program_action_template.action_wording
    else
      self.name
    end
  end
  
  def answer_type
    return nil unless self.trait.present?
    return self.trait.answer_type
  end
  
  def self.amount_units(user, a_type, trait = nil)
    if a_type == ':miles'
      return user.distance_pref
    elsif a_type == ':pounds'
      return user.weight_pref
    elsif Trait::ANSWER_TYPE[a_type].present?
      if a_type == ':quantity' and trait.present?
        return trait.noun_pl
      else
        return Trait::ANSWER_TYPE[a_type][:units]
      end
    else
      return nil
    end
    
  end
  
  def amount_units
    UserAction.amount_units(self.user, self.answer_type, self.trait)
  end
  
  def unit
    unit_text = self.trait.unit
    
    if unit_text == ':mile'
      return self.user.distance_pref
    else
      return unit_text
    end
  end
      
  # DEPRECATED 2/24/2012 by Buster with level up refactor
  def duration_in_days
    logger.warn "Deprecated... all user_actions should be 1 day. Reference program_budge for longer durations."
    return 1
  end
  
  def num_needed_for_completion
    (self.completion_requirement_number - self.num_times_done).to_i
  end

  def notification_url(message_type)
    self.notification(message_type).url
  end
  
  def notification(message_type)
    Notification.where(:for_object => message_type, :for_id => self.id).first
  end
          
  def dont?
    !self.do?
  end
  
  def added?
    self.status == ADDED
  end
  def started?
    self.status == STARTED
  end
  def skipped?
    self.status == SKIPPED
  end
  def ended_early?
    self.status == ENDED_EARLY
  end
  def completed?
    self.status == COMPLETED
  end
  def victorious?
    self.status == VICTORIOUS
  end
  def expired?
    self.status == EXPIRED
  end
  def done?
    self.skipped? or self.ended_early? or self.completed? or self.victorious? or self.expired?
  end
  def competed_or_victorious?
    self.completed? or self.victorious?
  end
  def not_done?
    !self.done?
  end
  
  def status_name
    case status
      when ADDED
        return 'added'
      when STARTED
        return 'started'
      when SKIPPED
        return 'skipped'
      when ENDED_EARLY
        return 'ended_early'
      when COMPLETED
        return 'completed'
      when VICTORIOUS
        return 'victorious'
    end
  end
      
  def scheduled?
    return false unless self.player_budge.present?
    if self.player_budge.scheduled?
      return true
    else
      return false
    end    
  end
  
  def in_progress?
    return false unless self.player_budge.present?
    if self.player_budge.in_progress?
      return true
    else
      return false
    end
  end

  def time_up?
    return false unless self.player_budge.present?
    if self.player_budge.time_up?
      return true
    else
      return false
    end
  end

  def needs_reviving?
    return false unless self.player_budge.present?
    if self.player_budge.needs_reviving?
      return true
    else
      return false
    end
  end
      
  def change_status(new_status)
    case new_status
      when :started
        self.update_attributes({:status => STARTED})
      when :skipped
        self.update_attributes({:status => SKIPPED})
      when :ended_early
        if self.in_progress?
          self.update_attributes({:status => ENDED_EARLY})
        end
      when :completed
        self.update_attributes({:status => COMPLETED})
      when :victorious
        self.update_attributes({:status => VICTORIOUS})  
      when :downgraded
        self.update_attributes({:status => STARTED})
      when :expired
        self.update_attributes({:status => EXPIRED})
    end
  end
  
  # Called from checkin.schedule_next_action_if_complete
  def schedule_next_day_or_budge(checkin = nil, check_for_downgrade = false)
    self.last_checkin_at = checkin.checkin_datetime if checkin.present?

    # Calculate num_times_done 
    self.sum_of_amount = self.checkins.sum(:amount_decimal)
    self.num_days_done = self.checkins.where(:desired_outcome => true).size

    # If the only requirement is that there be a certain number of "desired_outcome" checkins
    # completion_requirement_types = num_days_done, sum_of_amount, and duration
    if self.completion_requirement_type == 'action_complete' or 
      (self.completion_requirement_type == 'duration_over' and self.time_up?) then
      trait = self.trait
    
      # It's a do 
      if self.do? 
        
        # They've done it enough times
        if trait.complete_when_sum_of_amount? and 
          self.sum_of_amount >= self.completion_requirement_number and !self.victorious?
          self.change_status(:victorious)

        # They've done it enough days
        elsif trait.complete_when_num_days_done? and 
          self.num_days_done >= self.completion_requirement_number and !self.victorious?
          self.change_status(:victorious)
        
        # If time's up, then we just need to close the action
        elsif self.time_up? and !self.completed?
          self.change_status(:completed)
          
        elsif check_for_downgrade and !self.time_up? 
          
          if trait.complete_when_sum_of_amount? and
            self.sum_of_amount < self.completion_requirement_number and 
            (self.completed? or self.victorious?) then
          
            self.change_status(:downgraded)
            
          elsif trait.complete_when_num_days_done? and
            self.num_days_done < self.completion_requirement_number and 
            (self.completed? or self.victorious?) then

            self.change_status(:downgraded)
          end
        end
                
      # It's a don't
      elsif self.dont? 
        
        if trait.complete_when_sum_of_amount? and
          self.sum_of_amount > self.completion_requirement_number and !self.completed?
          self.change_status(:completed)
          
        elsif trait.complete_when_num_days_done? and
          self.num_days_done >= self.completion_requirement_number and !self.completed?
          self.change_status(:completed)

        elsif self.time_up? 
          if trait.complete_when_sum_of_amount? and 
            self.sum_of_amount <= self.completion_requirement_number and !self.victorious?
            self.change_status(:victorious)

          elsif trait.complete_when_num_days_done? and 
            self.num_days_done < self.completion_requirement_number and !self.victorious?
            self.change_status(:victorious)
          end
          
        elsif check_for_downgrade and !self.time_up? and 
          self.num_days_done < self.completion_requirement_number and
          (self.completed? or self.victorious?) then          
          self.change_status(:downgraded)

        end
      end      
    end
    self.save
  end

  # Depending on the trait, return the best number that captures the quantity of this user_action's trait
  def num_times_done
    if self.trait.complete_when_sum_of_amount?
      return self.sum_of_amount.to_f
    elsif self.trait.complete_when_num_days_done?
      return self.num_days_done.to_f
    else
      raise "invalid trait type"
    end
  end
  
  def reset_to_started
    self.user_likes.destroy_all
    self.user_comments.destroy_all
    self.checkins.destroy_all
    self.change_status(:started)
  end

  def reset_to_time_up
    self.reset_to_started
    self.update_attributes({:start_clock => Time.zone.now-2.days,
                            :end_clock => Time.zone.now-1.day})
  end
  
  def this_is_the_coach(user)
    return false unless user
    return true if user.id == self.coach_user_id
    return false 
  end 
  
  def this_is_the_player(user)
    return false if self.user_id.blank? or user.blank?
    return true if self.user_id == user.id
    return false
  end

  def destroy_related_stuff
    Checkin.destroy_all(:user_action_id => self.id)
    UserComment.destroy_all(:related_type => 'user_action', :related_id => self.id)
    UserLike.destroy_all(:related_type => 'user_action', :related_id => self.id)    
  end
    
end

# == Schema Information
#
# Table name: user_actions
#
#  id                            :integer(4)      not null, primary key
#  user_id                       :integer(4)
#  templated_action              :boolean(1)      default(FALSE)
#  trait_id                      :integer(4)
#  user_trait_id                 :integer(4)
#  created_at                    :datetime
#  updated_at                    :datetime
#  do                            :boolean(1)
#  name                          :string(255)
#  completion_requirement_type   :string(255)
#  completion_requirement_number :decimal(20, 2)
#  last_checkin_at               :datetime
#  custom_text                   :string(255)
#  sum_of_amount                 :integer(4)      default(0)
#  player_budge_id               :integer(4)
#  program_budge_id              :integer(4)
#  program_id                    :integer(4)
#  status                        :integer(4)      default(0)
#  program_action_template_id    :integer(4)
#  num_days_done                 :integer(4)      default(0)
#  day_number                    :integer(4)
#

