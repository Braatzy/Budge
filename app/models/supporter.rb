# == Schema Information
#
# Table name: supporters
#
#  id                    :integer(4)      not null, primary key
#  program_player_id     :integer(4)
#  program_id            :integer(4)
#  user_id               :integer(4)
#  invite_token          :string(255)
#  active                :boolean(1)      default(FALSE)
#  created_at            :datetime
#  updated_at            :datetime
#  user_twitter_username :string(255)
#  user_name             :string(255)
#  invite_message        :text
#

class Supporter < ActiveRecord::Base
  belongs_to :program
  belongs_to :program_player
  belongs_to :user
  
  def deliver_invite
    if (self.user.present? or self.user = User.find_by_twitter_username(self.user_twitter_username)) 
      send_results = self.user.contact_them(:dm_tweet, :invite_to_support, self)
    else
      send_results = User.non_user_contact(:dm_tweet, :invite_to_support, self)
    end
    return send_results
  end
end
