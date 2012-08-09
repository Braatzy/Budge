# == Schema Information
#
# Table name: foursquare_categories
#
#  id                 :integer(4)      not null, primary key
#  category_id        :string(255)
#  name               :string(255)
#  plural_name        :string(255)
#  icon               :string(255)
#  parent_id          :string(255)
#  parent_category_id :string(255)
#  num_children       :integer(4)      default(0)
#  level_deep         :integer(4)      default(1)
#  created_at         :datetime
#  updated_at         :datetime
#  trait_token        :string(255)
#

require 'test_helper'

class FoursquareCategoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
