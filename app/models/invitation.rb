require 'digest/md5'

class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :invited_user, :class_name => 'User'
  belongs_to :program
  belongs_to :program_player
  belongs_to :notification
  
  after_create :generate_token_and_notification
  
  def generate_token_and_notification
    time_in_user_time_zone = Time.now.in_time_zone(self.user.time_zone_or_default)

    # Create a notification object
    n = Notification.create({
          :user_id => nil,
          :delivered_via => :email,
          :message_style_token => 'invitation',
          :message_data => nil,
          :for_object => :invitation_to_program,
          :from_user_id => self.user_id,
          :from_system => false,
          :for_id => self.id,
          :delivered_immediately => true,
          :expected_response => true,
          :delivered => true,
          :delivered_at => Time.now.utc,
          :delivered_hour_of_day => time_in_user_time_zone.hour,
          :delivered_day_of_week => time_in_user_time_zone.wday,
          :delivered_week_of_year => time_in_user_time_zone.strftime('%W').to_i,
          :delivered_immediately => true,
          :delivered_off_hours => self.user.is_off_hours?})
    self.notification_id = n.id
    self.token = Digest::MD5.hexdigest("#{self.email}#{self.created_at}")
    self.save
  end
end

# == Schema Information
#
# Table name: invitations
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)
#  program_id        :integer(4)
#  token             :string(255)
#  email             :string(255)
#  invited_user_id   :integer(4)
#  visited           :boolean(1)      default(FALSE)
#  signed_up         :boolean(1)      default(FALSE)
#  bought_program    :boolean(1)      default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  program_player_id :integer(4)
#  notification_id   :integer(4)
#  message           :text
#

