require 'test_helper'

class UserBudgesControllerTest < ActionController::TestCase
  setup do
    @user_budge = user_budges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_budges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_budge" do
    assert_difference('UserBudge.count') do
      post :create, :user_budge => @user_budge.attributes
    end

    assert_redirected_to user_budge_path(assigns(:user_budge))
  end

  test "should show user_budge" do
    get :show, :id => @user_budge.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user_budge.to_param
    assert_response :success
  end

  test "should update user_budge" do
    put :update, :id => @user_budge.to_param, :user_budge => @user_budge.attributes
    assert_redirected_to user_budge_path(assigns(:user_budge))
  end

  test "should destroy user_budge" do
    assert_difference('UserBudge.count', -1) do
      delete :destroy, :id => @user_budge.to_param
    end

    assert_redirected_to user_budges_path
  end
end
