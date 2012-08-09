# == Schema Information
#
# Table name: twitter_scores
#
#  id                        :integer(4)      not null, primary key
#  date                      :date
#  twitter_id                :integer(4)
#  twitter_screen_name       :string(255)
#  klout_score               :decimal(5, 2)   default(0.0)
#  klout_slope               :decimal(5, 2)   default(0.0)
#  klout_class_id            :integer(4)
#  klout_class_name          :string(255)
#  klout_network_score       :decimal(5, 2)   default(0.0)
#  klout_amplification_score :decimal(5, 2)   default(0.0)
#  klout_true_reach          :integer(4)      default(0)
#  klout_delta_1day          :decimal(5, 2)   default(0.0)
#  klout_delta_5day          :decimal(5, 2)   default(0.0)
#  num_followers             :integer(4)      default(0)
#  num_following             :integer(4)      default(0)
#  num_tweets                :integer(4)      default(0)
#  created_at                :datetime
#  updated_at                :datetime
#

require 'test_helper'

class TwitterScoreTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
