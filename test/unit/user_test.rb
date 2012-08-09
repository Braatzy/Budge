require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end



# == Schema Information
#
# Table name: users
#
#  id                             :integer(4)      not null, primary key
#  name                           :string(255)
#  email                          :string(255)
#  hashed_password                :string(255)
#  salt                           :string(255)
#  time_zone                      :string(255)
#  gender                         :string(255)
#  birthday_day                   :integer(4)
#  birthday_month                 :integer(4)
#  birthday_year                  :integer(4)
#  email_verified                 :boolean(1)      default(FALSE)
#  photo_file_name                :string(255)
#  photo_content_type             :string(255)
#  photo_file_size                :integer(4)
#  get_notifications              :boolean(1)      default(TRUE)
#  get_news                       :boolean(1)      default(TRUE)
#  no_notifications_before        :integer(4)      default(8)
#  no_notifications_after         :integer(4)      default(22)
#  last_logged_in                 :datetime
#  use_metric                     :boolean(1)      default(FALSE)
#  bio                            :text
#  created_at                     :datetime
#  updated_at                     :datetime
#  facebook_uid                   :string(255)
#  admin                          :boolean(1)      default(FALSE)
#  relationship_status            :string(255)
#  level_up_credits               :integer(4)      default(0)
#  num_notifications              :integer(4)      default(0)
#  total_level_up_credits_earned  :integer(4)      default(0)
#  meta_level                     :integer(4)      default(0)
#  phone                          :string(255)
#  phone_normalized               :string(255)
#  phone_verified                 :boolean(1)      default(FALSE)
#  facebook_username              :string(255)
#  twitter_username               :string(255)
#  contact_by_email_pref          :integer(4)      default(10)
#  contact_by_sms_pref            :integer(4)      default(10)
#  contact_by_public_tweet_pref   :integer(4)      default(5)
#  contact_by_dm_tweet_pref       :integer(4)      default(5)
#  contact_by_robocall_pref       :integer(4)      default(0)
#  contact_by_email_score         :decimal(10, 8)  default(10.0)
#  contact_by_sms_score           :decimal(10, 8)  default(10.0)
#  contact_by_public_tweet_score  :decimal(10, 8)  default(10.0)
#  contact_by_dm_tweet_score      :decimal(10, 8)  default(10.0)
#  contact_by_robocall_score      :decimal(10, 8)  default(10.0)
#  visit_streak                   :integer(4)      default(0)
#  contact_by_facebook_wall_pref  :decimal(10, 8)  default(5.0)
#  contact_by_facebook_wall_score :decimal(10, 8)  default(10.0)
#  contact_by_friend_pref         :decimal(10, 8)  default(1.0)
#  contact_by_friend_score        :decimal(10, 8)  default(10.0)
#  meta_level_alignment           :integer(4)
#  meta_level_role                :string(255)
#  meta_level_name                :string(255)
#  addon_cache                    :text
#  coach                          :boolean(1)      default(FALSE)
#  visit_stats_updated            :datetime
#  visit_stats_sample_size        :integer(4)      default(0)
#  streak_level                   :integer(4)      default(0)
#  has_braintree                  :boolean(1)      default(FALSE)
#  distance_units                 :integer(4)      default(0)
#  weight_units                   :integer(4)      default(0)
#  currency_units                 :integer(4)      default(0)
#  withings_user_id               :string(255)
#  withings_public_key            :string(255)
#  withings_username              :string(255)
#  withings_subscription_renew_by :date
#  last_latitude                  :decimal(15, 10)
#  last_longitude                 :decimal(15, 10)
#  lat_long_updated_at            :datetime
#  next_nudge_at                  :datetime
#  in_beta                        :boolean(1)      default(FALSE)
#  last_location_context_id       :integer(4)
#  dollars_credit                 :decimal(8, 2)   default(0.0)
#  send_phone_verification        :boolean(1)      default(FALSE)
#  status                         :string(255)     default("interested")
#  officially_started_at          :datetime
#  cohort_tag                     :string(255)
#  invited_to_beta                :boolean(1)      default(FALSE)
#

