# == Schema Information
#
# Table name: points
#
#  id              :integer(4)      not null, primary key
#  checkin_id      :integer(4)
#  user_id         :integer(4)
#  num_points      :integer(4)      default(0)
#  point_type      :string(255)
#  related_user_id :integer(4)
#  do_trait        :boolean(1)
#  user_action_id  :integer(4)
#  trait_id        :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  pack_token      :string(255)
#

require 'test_helper'

class PointTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
