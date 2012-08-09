# == Schema Information
#
# Table name: user_traits
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)      not null
#  trait_id          :integer(4)      not null
#  level             :integer(4)      default(0)
#  created_at        :datetime
#  updated_at        :datetime
#  do_points         :integer(4)      default(0)
#  dont_points       :integer(4)      default(0)
#  coach_do_points   :integer(4)      default(0)
#  coach_dont_points :integer(4)      default(0)
#

require 'test_helper'

class UserTraitTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
