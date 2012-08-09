require 'test_helper'

class OauthControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "connects to facebook" do 
    get :facebook
    assert_response :redirect
  end
end
