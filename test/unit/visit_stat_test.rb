# == Schema Information
#
# Table name: visit_stats
#
#  id                 :integer(4)      not null, primary key
#  constrained_by     :string(255)
#  constrained_by_id1 :string(255)
#  constrained_by_id2 :string(255)
#  constrained_by_id3 :string(255)
#  num_visits         :integer(4)      default(0)
#  percent_visits     :decimal(5, 2)   default(0.0)
#  created_at         :datetime
#  updated_at         :datetime
#

require 'test_helper'

class VisitStatTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
