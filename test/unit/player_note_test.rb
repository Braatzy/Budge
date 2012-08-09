# == Schema Information
#
# Table name: player_notes
#
#  id                :integer(4)      not null, primary key
#  program_player_id :integer(4)
#  about_user_id     :integer(4)
#  note_about        :string(255)
#  text              :text
#  created_at        :datetime
#  updated_at        :datetime
#

require 'test_helper'

class PlayerNoteTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
