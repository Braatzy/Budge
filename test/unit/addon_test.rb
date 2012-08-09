# == Schema Information
#
# Table name: addons
#
#  id                     :integer(4)      not null, primary key
#  token                  :string(255)
#  name                   :string(255)
#  visible_at_level       :integer(4)      default(0)
#  level_credit_cost      :integer(4)      default(0)
#  dollar_cost            :decimal(6, 2)   default(0.0)
#  created_at             :datetime
#  updated_at             :datetime
#  parent_id              :integer(4)
#  purchasable            :boolean(1)      default(TRUE)
#  description            :string(255)
#  auto_unlocked_at_level :integer(4)
#

require 'test_helper'

class AddonTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
