require 'test_helper'

class BudgeRequestsControllerTest < ActionController::TestCase
  setup do
    @budge_request = budge_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:budge_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create budge_request" do
    assert_difference('BudgeRequest.count') do
      post :create, :budge_request => @budge_request.attributes
    end

    assert_redirected_to budge_request_path(assigns(:budge_request))
  end

  test "should show budge_request" do
    get :show, :id => @budge_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @budge_request.to_param
    assert_response :success
  end

  test "should update budge_request" do
    put :update, :id => @budge_request.to_param, :budge_request => @budge_request.attributes
    assert_redirected_to budge_request_path(assigns(:budge_request))
  end

  test "should destroy budge_request" do
    assert_difference('BudgeRequest.count', -1) do
      delete :destroy, :id => @budge_request.to_param
    end

    assert_redirected_to budge_requests_path
  end
end
