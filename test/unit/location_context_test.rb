# == Schema Information
#
# Table name: location_contexts
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  context_about          :string(255)
#  context_id             :integer(4)
#  latitude               :decimal(15, 10)
#  longitude              :decimal(15, 10)
#  population_density     :integer(4)      default(0)
#  temperature_f          :integer(4)
#  weather_conditions     :string(255)
#  simplegeo_context      :text
#  foursquare_place_id    :string(255)
#  foursquare_category_id :string(255)
#  foursquare_checkin_id  :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  foursquare_context     :text
#  foursquare_guess       :boolean(1)      default(FALSE)
#  place_name             :string(255)
#  possible_duplicate     :boolean(1)      default(FALSE)
#

require 'test_helper'

class LocationContextTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
