# == Schema Information
#
# Table name: user_comments
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)      not null
#  related_id      :integer(4)      not null
#  related_type    :string(255)     not null
#  comment_text    :text            default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#  comment_type    :string(255)
#  comment_type_id :string(255)
#

require 'test_helper'

class UserCommentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
