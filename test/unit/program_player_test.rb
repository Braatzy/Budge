require 'test_helper'

class ProgramPlayerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: program_players
#
#  id                            :integer(4)      not null, primary key
#  program_id                    :integer(4)
#  user_id                       :integer(4)
#  player_budge_id               :integer(4)
#  last_visited_at               :datetime
#  needs_coach_at                :datetime
#  created_at                    :datetime
#  updated_at                    :datetime
#  wants_to_change               :string(255)
#  how_badly                     :string(255)
#  success_statement             :string(255)
#  latest_tweet_id               :string(255)
#  active                        :boolean(1)      default(TRUE)
#  coach_note                    :string(255)
#  num_messages_to_coach         :integer(4)      default(0)
#  num_messages_from_coach       :integer(4)      default(0)
#  level                         :integer(4)      default(1)
#  max_level                     :integer(4)      default(1)
#  coach_user_id                 :integer(4)
#  required_answer_1             :text
#  required_answer_2             :text
#  optional_answer_1             :text
#  optional_answer_2             :text
#  restart_at                    :date
#  restart_day_number            :integer(4)
#  onboarding_complete           :boolean(1)      default(FALSE)
#  start_date                    :date
#  coach_data                    :text
#  program_coach_id              :integer(4)
#  score_data                    :text
#  completed                     :boolean(1)      default(FALSE)
#  program_coach_subscription_id :string(255)
#  program_coach_subscribed_at   :date
#  program_coach_rating          :integer(4)
#  program_coach_testimonial     :text
#  program_coach_recommended     :boolean(1)
#  program_coach_rated_at        :datetime
#  needs_to_play_at              :datetime
#  num_supporter_invites         :integer(4)      default(1)
#  coach_flag                    :integer(4)
#  needs_coach_pitch             :boolean(1)      default(TRUE)
#  needs_survey_pitch            :boolean(1)      default(TRUE)
#  testimonial                   :text
#  num_invites_sent              :integer(4)      default(0)
#  num_invites_viewed            :integer(4)      default(0)
#  num_invites_accepted          :integer(4)      default(0)
#  num_invites_available         :integer(4)      default(1)
#  needs_contact_info            :boolean(1)      default(TRUE)
#  hardcoded_reminder_hour       :integer(4)
#  last_checked_in               :datetime
#  victorious                    :boolean(1)
#

