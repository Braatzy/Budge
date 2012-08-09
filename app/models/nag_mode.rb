class NagMode < ActiveRecord::Base
  has_many :nag_mode_prompts, :dependent => :destroy, :order => [:day_number, :at_hour, :at_wakeup_time]

  def self.testcall(template = 'launch_demo')
    TwilioApi.robocall("12063559718", template)    
  end

  def self.send_nags
    nag_modes_hash = NagMode.nag_modes_hash
  
    sent_prompts = []
    UserNagMode.where(:active => true).each do |user_nag_mode|
      user = user_nag_mode.user
      if user_nag_mode == user.user_nag_mode
        sent_prompts << user_nag_mode.send_nag(nag_modes_hash)
      else
        user_nag_mode.update_attributes(:active => false)
      end
    end
    return sent_prompts
  end

  def self.nag_modes_hash
    # Load all of the nag modes
    nag_modes = Hash.new
    NagMode.all.each do |nm|
      nag_modes[nm.id] = {:nag_mode => nm, :prompts => Hash.new}
    end
    
    # Load all nag mode prompts
    NagModePrompt.all.each do |nag_mode_prompt|
      if nag_mode_prompt.at_hour.present?
        nag_modes[nag_mode_prompt.nag_mode_id][:prompts][nag_mode_prompt.at_hour] ||= Array.new
        nag_modes[nag_mode_prompt.nag_mode_id][:prompts][nag_mode_prompt.at_hour] << nag_mode_prompt            
      
      elsif nag_mode_prompt.at_wakeup_time?
        nag_modes[nag_mode_prompt.nag_mode_id][:prompts][:waketime] ||= Array.new
        nag_modes[nag_mode_prompt.nag_mode_id][:prompts][:waketime] << nag_mode_prompt            
      
      elsif nag_mode_prompt.at_bedtime?
        nag_modes[nag_mode_prompt.nag_mode_id][:prompts][:bedtime] ||= Array.new
        nag_modes[nag_mode_prompt.nag_mode_id][:prompts][:bedtime] << nag_mode_prompt            
      end
    end
    return nag_modes
  end
end

# == Schema Information
#
# Table name: nag_modes
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  num_days    :integer(4)      default(7)
#  price       :decimal(5, 2)   default(0.0)
#  created_at  :datetime
#  updated_at  :datetime
#

