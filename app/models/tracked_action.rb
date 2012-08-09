# == Schema Information
#
# Table name: tracked_actions
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  token               :string(255)
#  num_triggers        :integer(4)      default(0)
#  trigger_data        :string(255)
#  tag_week            :integer(4)
#  tag_month           :integer(4)
#  tag_year            :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#  num_days_this_week  :integer(4)      default(0)
#  num_days_this_month :integer(4)      default(0)
#

class TrackedAction < ActiveRecord::Base
  belongs_to :user
  serialize :trigger_data
  serialize :token

  # Kinds of tracked_actions:
  # visited, signed_up, logged_in, logged_out
  # successful_invite, successful_budge (these are not Behaviors)
  
  def self.user_has_token(user, token)
    return nil unless user and token
    tracked_actions = TrackedAction.where(:token => token.to_s, :user_id => user.id).first
    if tracked_actions.present?
      return true
    else
      return false
    end
  end

  def self.add(token, user, timestamp = Time.zone.now)
    return nil unless user
    tracked_action = TrackedAction.find_or_initialize_by_token_and_user_id_and_tag_week_and_tag_year(token.to_s, user.id, timestamp.strftime('%W').to_i, timestamp.year)        
    # Create a new tracked_action every month
    if tracked_action.new_record? 
      tracked_action.attributes = {:tag_month => Time.zone.now.month}
    end
    
    #ARG: I'm not sure I follow this. Could we look over this and make sure it is working? It seems to be reporting visitation stats that don't jive with user.last_logged_in. (e.g. Rick Webb). 
    tracked_action.num_triggers += 1
    tracked_action.trigger_data ||= Hash.new
    tracked_action.trigger_data[timestamp.to_date] ||= 0
    tracked_action.trigger_data[timestamp.to_date] += 1
    tracked_action.num_days_this_week = tracked_action.trigger_data.size
    tracked_action.save        
    tracked_action.update_attributes({:num_days_this_month => TrackedAction.sum(:num_days_this_week, 
                                                                                :conditions => {:token => token, 
                                                                                                :user_id => user.id,
                                                                                                :tag_month => tracked_action.tag_month})})
  end
  
  def self.tracked_action_hash_for_user(user)
    tracked_action_hash = Hash.new
    user.tracked_actions.each do |tracked_action|
      tracked_action_hash[tracked_action.token] = tracked_action
    end
    return tracked_action_hash
  end
  
end
