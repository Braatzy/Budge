class UserNagMode < ActiveRecord::Base
  belongs_to :user
  belongs_to :nag_mode
  belongs_to :program
  belongs_to :program_player
  
  def self.start_nag_mode(nag_mode, program_player)
    user = program_player.user
    
    if user.nag_mode_is_on?
      return nil
    else
      date = Time.now.in_time_zone(user.time_zone_or_default).to_date
      user_nag_mode = UserNagMode.create({:user_id => user.id,
                                          :nag_mode_id => nag_mode.id,
                                          :program_id => program_player.program_id,
                                          :program_player_id => program_player.id,
                                          :active => true,
                                          :start_date => date,
                                          :end_date => date+nag_mode.num_days.days})

      # Make sure that they can get robocalls
      if user.contact_by_robocall_pref < 1
        user.update_attributes(:contact_by_robocall_pref => 1)
      end    

      # Pause all the rest of their programs for a week
      user.valid_program_players.each do |pp|
        next if pp.id == program_player.id
        next unless pp.player_budge.present? and pp.player_budge.playing?
        
        pp.player_budge.move_to_day(pp.player_budge.day_of_budge, (date+nag_mode.num_days.days))
      end
      
      return user_nag_mode  
    end
  end
  
  def send_nag(nag_modes_hash = nil)    
    nag_modes_hash ||= NagMode.nag_modes_hash
    pp = self.program_player
    
    nag_mode_prompt = nil
    
    if pp.needs_to_play_at.present? and pp.needs_to_play_at < Time.now.utc
      user = self.user
      current_time = Time.now.in_time_zone(user.time_zone_or_default)
      current_date = current_time.to_date
      current_hour = current_time.hour
      nag_day_number = (current_date - self.start_date)+1
      bedtime = user.no_notifications_after
      waketime = user.no_notifications_before
      nag_mode_hash = nag_modes_hash[self.nag_mode_id]
      
      potential_prompts = Array.new
      # Check to see if it's wakeup time, send first prompt
      if current_hour == waketime and nag_mode_hash[:prompts][:waketime].present?
        potential_prompts.push(nag_mode_hash[:prompts][:waketime]).flatten!
      
      # Check to see if it's bedtime, send first prompt
      elsif current_hour == (bedtime-1) and nag_mode_hash[:prompts][:bedtime].present?
        potential_prompts.push(nag_mode_hash[:prompts][:bedtime]).flatten!
      
      # Check to see if there's one for this hour
      elsif nag_mode_hash[:prompts][current_hour].present?
        potential_prompts.push(nag_mode_hash[:prompts][current_hour]).flatten!
    
      # Prefer prompts that specify a day number over those that don't
      nag_prompt_to_send = potential_prompts.select{|p|p.day_number == nag_day_number}.first
      if nag_prompt_to_send.blank?
        nag_prompt_to_send = potential_prompts.select{|p|p.day_number.blank?}.first
      end  
      if nag_prompt_to_send.present?
        if nag_prompt_to_send.via.to_sym == :robocall and user.can_robocall?
          TwilioApi.robocall(user.phone_normalized, 'nag_mode', nag_prompt_to_send.id, pp.id)
        else
          user.contact_them(nag_prompt_to_send.via.to_sym, :nag_prompt, nag_prompt_to_send)  
        end
        return nag_prompt_to_send
      end
    else
      # Is all caught up or scheduled for the future
    end
  end
    
  
  end
end

# == Schema Information
#
# Table name: user_nag_modes
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)
#  nag_mode_id       :integer(4)
#  start_date        :date
#  end_date          :date
#  program_id        :integer(4)
#  program_player_id :integer(4)
#  active            :boolean(1)      default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#

