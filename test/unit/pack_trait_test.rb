# == Schema Information
#
# Table name: pack_traits
#
#  id         :integer(4)      not null, primary key
#  trait_id   :integer(4)      not null
#  pack_id    :integer(4)      not null
#  level      :integer(4)      default(1)
#  position   :integer(4)      default(1000)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class PackBehaviorTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
