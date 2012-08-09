require 'test_helper'

class TraitTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: traits
#
#  id                 :integer(4)      not null, primary key
#  token              :string(255)
#  primary_pack_token :string(255)
#  do_name            :string(255)
#  dont_name          :string(255)
#  parent_trait_id    :integer(4)
#  setup_required     :boolean(1)      default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  name               :string(255)
#  verb               :string(255)
#  noun               :string(255)
#  answer_type        :string(255)
#  daily_question     :string(255)
#  noun_pl            :string(255)
#  article            :string(255)
#  past_template      :string(255)
#  hashtag            :string(255)
#

