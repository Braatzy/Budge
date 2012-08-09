class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :followed_user, :class_name => 'User'
    
  def update_stats
    Relationship.update_stats_for(self.user, self.followed_user)
  end  
  
  def active?
    !self.invisible? and !self.blocked? and self.reverse_relationship.present? and !self.reverse_relationship.blocked?
  end
  
  def reverse_relationship
    Relationship.where(:user_id => self.followed_user_id, :followed_user_id => self.user_id).first
  end
  
  def notify_followee
    return unless Rails.env.production? and !self.invisible? and !self.blocked? and !self.notified_followee? and self.followed_user.present?
    self.followed_user.contact_them(:email, :new_follower, self)
    self.update_attributes(:notified_followee => true)
  end
  
end

# Buster deleted self.update_stats_for(user1,user2) on 9/27/2011

# == Schema Information
#
# Table name: relationships
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  followed_user_id       :integer(4)
#  read                   :boolean(1)      default(FALSE)
#  auto                   :boolean(1)      default(FALSE)
#  invisible              :boolean(1)      default(FALSE)
#  blocked                :boolean(1)      default(FALSE)
#  from                   :string(255)
#  found_on_other_network :boolean(1)      default(FALSE)
#  facebook_friends       :boolean(1)      default(FALSE)
#  twitter_friends        :boolean(1)      default(FALSE)
#  foursquare_friends     :boolean(1)      default(FALSE)
#  referred_signup        :boolean(1)      default(FALSE)
#  referred_signup_via    :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  notified_followee      :boolean(1)      default(FALSE)
#

