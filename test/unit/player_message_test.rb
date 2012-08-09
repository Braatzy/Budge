require 'test_helper'

class PlayerMessageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: player_messages
#
#  id                :integer(4)      not null, primary key
#  from_user_id      :integer(4)
#  from_remote_user  :string(255)
#  to_user_id        :integer(4)
#  to_remote_user    :string(255)
#  content           :text
#  program_player_id :integer(4)
#  player_budge_id   :integer(4)
#  remote_post_id    :string(255)
#  message_data      :text
#  delivered         :boolean(1)      default(FALSE)
#  deliver_at        :datetime
#  from_coach        :boolean(1)      default(FALSE)
#  to_coach          :boolean(1)      default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  program_id        :integer(4)
#  program_budge_id  :integer(4)
#  error             :string(255)
#  send_attempts     :integer(4)      default(0)
#  subject           :string(255)
#  auto_message_id   :integer(4)
#  delivered_via     :integer(4)      default(0)
#  deliver_via_pref  :integer(4)
#  trigger_trait_id  :integer(4)
#  entry_id          :integer(4)
#  to_player         :boolean(1)      default(FALSE)
#  to_supporters     :boolean(1)      default(FALSE)
#  checkin_id        :integer(4)
#  message_type      :integer(4)      default(0)
#

