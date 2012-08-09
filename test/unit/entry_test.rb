require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: entries
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)      not null
#  program_player_id   :integer(4)
#  program_id          :integer(4)
#  program_budge_id    :integer(4)
#  player_message_id   :integer(4)
#  tweet_id            :string(255)
#  facebook_post_id    :string(255)
#  location_context_id :integer(4)
#  message             :text
#  message_type        :string(255)
#  privacy_setting     :integer(4)      default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  post_to_coach       :boolean(1)      default(FALSE)
#  post_to_twitter     :boolean(1)      default(FALSE)
#  post_to_facebook    :boolean(1)      default(FALSE)
#  date                :date
#  player_budge_id     :integer(4)
#  parent_id           :integer(4)
#  original_message    :string(255)
#  metadata            :text
#  checkin_id          :integer(4)
#

