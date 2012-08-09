require 'test_helper'

class CheckinTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: checkins
#
#  id                           :integer(4)      not null, primary key
#  user_id                      :integer(4)
#  is_player                    :boolean(1)      default(TRUE)
#  user_action_id               :integer(4)
#  trait_id                     :integer(4)      not null
#  latitude                     :decimal(15, 10)
#  longitude                    :decimal(15, 10)
#  did_action                   :boolean(1)      default(FALSE)
#  desired_outcome              :boolean(1)      default(TRUE)
#  comment                      :text
#  amount_integer               :integer(4)      default(0)
#  amount_decimal               :decimal(10, 2)
#  amount_string                :string(255)
#  amount_text                  :text
#  checkin_datetime             :datetime
#  checkin_datetime_approximate :boolean(1)      default(FALSE)
#  hour_of_day                  :integer(4)
#  day_of_week                  :integer(4)
#  week_of_year                 :integer(4)
#  checkin_via                  :string(255)
#  end_clock_remaining          :integer(4)
#  created_at                   :datetime
#  updated_at                   :datetime
#  player_leveled_up            :boolean(1)      default(FALSE)
#  coach_leveled_up             :boolean(1)      default(FALSE)
#  amount_units                 :string(255)
#  user_trait_id                :integer(4)      not null
#  date                         :date
#  remote_id                    :string(255)
#  stars_for_participation      :decimal(11, 10) default(0.0)
#  stars_for_mastery            :decimal(11, 10) default(0.0)
#  stars_for_commenting         :decimal(11, 10) default(0.0)
#  stars_total                  :decimal(11, 10) default(0.0)
#  player_budge_id              :integer(4)
#  duplicate                    :boolean(1)      default(FALSE)
#  program_player_id            :integer(4)
#  raw_text                     :text
#

