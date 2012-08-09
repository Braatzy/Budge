# == Schema Information
#
# Table name: link_resources
#
#  id                 :integer(4)      not null, primary key
#  url                :string(255)
#  bitly_url          :string(255)
#  bitly_hash         :string(255)
#  bitly_stats        :text
#  url_title          :string(255)
#  domain             :string(255)
#  description        :text
#  link_type          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer(4)
#

require 'test_helper'

class LinkResourceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
