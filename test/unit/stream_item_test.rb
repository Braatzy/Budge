# == Schema Information
#
# Table name: stream_items
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  item_type      :string(255)
#  related_id     :integer(4)
#  related_sub_id :integer(4)
#  text           :text
#  data           :text
#  private        :boolean(1)      default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class StreamItemTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
