# == Schema Information
#
# Table name: daily_grrs
#
#  id                    :integer(4)      not null, primary key
#  date                  :date            not null
#  signups               :integer(4)      default(0)
#  logins_1day           :integer(4)      default(0)
#  logins_7day           :integer(4)      default(0)
#  revenue               :decimal(10, 2)  default(0.0)
#  created_at            :datetime
#  updated_at            :datetime
#  total_users           :integer(4)      default(0)
#  invitations_sent      :integer(4)      default(0)
#  invitations_redeemed  :integer(4)      default(0)
#  notifications_sent    :integer(4)      default(0)
#  notifications_clicked :integer(4)      default(0)
#

class DailyGrr < ActiveRecord::Base

  def self.save_last_day
    @total_users = User.where(:in_beta => true).where('last_logged_in is not null').size
    @new_users_in_last_day = User.where('created_at >= ? AND in_beta = ?', Time.zone.now-1.day, true).size
    @logged_in_users_in_last_day = User.where('last_logged_in >= ? AND in_beta = ?', Time.zone.now-1.day, true).size
    @logged_in_users_in_last_week = User.where('last_logged_in >= ? AND in_beta = ?', Time.zone.now-7.days, true).size
    @charges_in_last_day = Charge.where('created_at >= ?', Time.zone.now-1.day).sum(:amount)
    @invitations_sent = Invitation.where('created_at >= ?', Time.zone.now-1.day)
    @invitations_redeemed = @invitations_sent.select{|i|i.signed_up?}
    @notifications_sent = Notification.where('expected_response = ? AND created_at >= ?', true, Time.zone.now-1.day)
    @notifications_clicked = @notifications_sent.select{|i|i.total_clicks > 0}
    
    @daily_grr = DailyGrr.find_or_create_by_date((Time.zone.now-1.day).to_date)
    @daily_grr.attributes = {:total_users => @total_users,
                             :signups => @new_users_in_last_day,
                             :logins_1day => @logged_in_users_in_last_day,
                             :logins_7day => @logged_in_users_in_last_week,
                             :revenue => @charges_in_last_day,
                             :invitations_sent => @invitations_sent.size,
                             :invitations_redeemed => @invitations_redeemed.size,
                             :notifications_sent => @notifications_sent.size,
                             :notifications_clicked => @notifications_clicked.size}
    @daily_grr.save  
    @active_users = User.where('visit_streak > 0 AND in_beta = ?', true).order('visit_streak desc').limit(50)    
    Mailer.daily_grr(@daily_grr, @active_users).deliver
  end
end
