# == Schema Information
#
# Table name: notifications
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  short_id               :string(255)
#  delivered              :boolean(1)      default(FALSE)
#  delivered_at           :datetime
#  delivered_hour_of_day  :integer(4)
#  delivered_day_of_week  :integer(4)
#  delivered_week_of_year :integer(4)
#  responded_at           :datetime
#  responded_hour_of_day  :integer(4)
#  responded_day_of_week  :integer(4)
#  responded_week_of_year :integer(4)
#  delivered_via          :string(255)
#  message_style_token    :string(255)
#  message_data           :text
#  responded_minutes      :integer(4)
#  total_clicks           :integer(4)      default(0)
#  responded              :boolean(1)      default(FALSE)
#  completed_response     :boolean(1)      default(FALSE)
#  method_of_response     :integer(4)
#  shared_results         :boolean(1)      default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#  remote_user_id         :string(255)
#  remote_site_token      :string(255)
#  remote_post_id         :string(255)
#  delivered_immediately  :boolean(1)      default(FALSE)
#  num_signups            :integer(4)      default(0)
#  for_object             :string(255)
#  for_id                 :integer(4)
#  from_system            :boolean(1)      default(FALSE)
#  from_user_id           :integer(4)
#  delivered_off_hours    :boolean(1)      default(FALSE)
#  broadcast              :boolean(1)      default(FALSE)
#  ref_site               :string(255)
#  ref_url                :string(255)
#  expected_response      :boolean(1)      default(FALSE)
#

require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
