# == Schema Information
#
# Table name: oauth_tokens
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  site_token             :string(255)
#  site_name              :string(255)
#  token                  :string(255)
#  secret                 :string(255)
#  remote_name            :string(255)
#  remote_username        :string(255)
#  remote_user_id         :string(255)
#  cached_user_info       :text
#  cached_datetime        :datetime
#  working                :boolean(1)      default(TRUE)
#  created_at             :datetime
#  updated_at             :datetime
#  post_pref_on           :boolean(1)      default(FALSE)
#  friend_id_hash         :text
#  friend_id_hash_updated :datetime
#  latest_dm_id           :string(255)
#  primary_token          :boolean(1)      default(TRUE)
#

require 'test_helper'

class OauthTokenTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
