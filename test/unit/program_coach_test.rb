# == Schema Information
#
# Table name: program_coaches
#
#  id                               :integer(4)      not null, primary key
#  program_id                       :integer(4)
#  user_id                          :integer(4)
#  primary_oauth_token_id           :integer(4)
#  price                            :decimal(6, 2)   default(0.0)
#  message                          :text
#  total_players                    :integer(4)      default(0)
#  num_active                       :integer(4)      default(0)
#  num_snoozed                      :integer(4)      default(0)
#  num_completed                    :integer(4)      default(0)
#  num_victorious                   :integer(4)      default(0)
#  percent_victorious               :decimal(5, 2)   default(0.0)
#  avg_days_to_completion           :decimal(7, 2)   default(0.0)
#  avg_days_to_victory              :integer(4)      default(0)
#  avg_rating                       :integer(4)      default(0)
#  level                            :integer(4)      default(1)
#  currently_accepting_applications :boolean(1)      default(FALSE)
#  head_coach                       :boolean(1)      default(FALSE)
#  created_at                       :datetime
#  updated_at                       :datetime
#  percent_completed                :decimal(5, 2)
#  num_scheduled                    :integer(4)      default(0)
#  num_budgeless                    :integer(4)      default(0)
#  coaching_style                   :string(255)
#  num_active_and_unflagged         :integer(4)      default(0)
#  num_flagged                      :integer(4)      default(0)
#  max_active_and_unflagged         :integer(4)      default(10)
#

require 'test_helper'

class ProgramCoachTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
