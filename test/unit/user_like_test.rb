# == Schema Information
#
# Table name: user_likes
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  related_id   :integer(4)      not null
#  related_type :string(255)     not null
#  created_at   :datetime
#  updated_at   :datetime
#

require 'test_helper'

class UserLikeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
