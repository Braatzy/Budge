# == Schema Information
#
# Table name: user_addons
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  addon_id            :integer(4)
#  level_credits_spent :integer(4)      default(0)
#  dollars_spent       :integer(10)     default(0)
#  activated           :boolean(1)      default(TRUE)
#  created_at          :datetime
#  updated_at          :datetime
#  num_owned           :integer(4)      default(1)
#  given_to            :text
#  given_by            :text
#

require 'test_helper'

class UserAddonTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
