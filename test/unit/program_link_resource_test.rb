# == Schema Information
#
# Table name: program_link_resources
#
#  id                :integer(4)      not null, primary key
#  program_id        :integer(4)
#  link_resource_id  :integer(4)
#  program_budge_id  :integer(4)
#  user_id           :integer(4)
#  short_description :string(255)
#  long_description  :text
#  importance        :integer(4)      default(0)
#  created_at        :datetime
#  updated_at        :datetime
#

require 'test_helper'

class ProgramLinkResourceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
