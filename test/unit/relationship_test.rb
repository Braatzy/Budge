require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: relationships
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  followed_user_id       :integer(4)
#  read                   :boolean(1)      default(FALSE)
#  auto                   :boolean(1)      default(FALSE)
#  invisible              :boolean(1)      default(FALSE)
#  blocked                :boolean(1)      default(FALSE)
#  from                   :string(255)
#  found_on_other_network :boolean(1)      default(FALSE)
#  facebook_friends       :boolean(1)      default(FALSE)
#  twitter_friends        :boolean(1)      default(FALSE)
#  foursquare_friends     :boolean(1)      default(FALSE)
#  referred_signup        :boolean(1)      default(FALSE)
#  referred_signup_via    :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  notified_followee      :boolean(1)      default(FALSE)
#

