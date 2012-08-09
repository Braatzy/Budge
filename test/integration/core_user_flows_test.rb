require 'test_helper'

class CoreUserFlowsTest < ActionDispatch::IntegrationTest
    fixtures :all

    # Replace this with your real tests.
    setup do
        current_user = login(:one)
        assert_equal 1, current_user.id
    end
    
    test "create user" do
        assert_equal false, current_user.new_record?
        assert_equal 1, current_user.user_budges.size
        assert_equal 1, current_user.user_budges.unread.size        

        get "/home"
        assert_select 'title', 'Budge'
    end
    
    test "process budge request" do 
        @budge_request = budge_requests(:one)
        
        BudgeRequest.post_requests_to_social_networks(@budge_request.id)
    end
end
