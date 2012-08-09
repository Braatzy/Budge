# == Schema Information
#
# Table name: program_drafts
#
#  id         :integer(4)      not null, primary key
#  plaintext  :text
#  data       :text
#  version    :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class ProgramDraftTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
