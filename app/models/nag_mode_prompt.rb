class NagModePrompt < ActiveRecord::Base
  belongs_to :nag_mode

  before_save :only_one_trigger

  def only_one_trigger
    if self.at_hour.present?
      self.at_wakeup_time = false
      self.at_bedtime = false
    elsif self.at_wakeup_time?
      self.at_hour = nil
      self.at_bedtime = false
    elsif self.at_bedtime?
      self.at_hour = nil
      self.at_wakeup_time = false
    end
    return true
  end
  
  def parsed_message(options = {})
    # :user, :user_nag_mode
    message = self.message
    message = message.gsub("[name]", options[:user].first_name) if options[:user].present?    
    message = message.gsub("[program]", options[:user_nag_mode].program.name) if options[:user_nag_mode].present?    
    return message
  end
end

# == Schema Information
#
# Table name: nag_mode_prompts
#
#  id             :integer(4)      not null, primary key
#  nag_mode_id    :integer(4)
#  day_number     :integer(4)
#  at_hour        :integer(4)
#  at_wakeup_time :boolean(1)      default(FALSE)
#  at_bedtime     :boolean(1)      default(FALSE)
#  via            :string(255)     default("sms")
#  message        :text
#  created_at     :datetime
#  updated_at     :datetime
#

