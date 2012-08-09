require 'test_helper'

class UserAddonsControllerTest < ActionController::TestCase
  setup do
    @user_addon = user_addons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_addons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_addon" do
    assert_difference('UserAddon.count') do
      post :create, :user_addon => @user_addon.attributes
    end

    assert_redirected_to user_addon_path(assigns(:user_addon))
  end

  test "should show user_addon" do
    get :show, :id => @user_addon.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user_addon.to_param
    assert_response :success
  end

  test "should update user_addon" do
    put :update, :id => @user_addon.to_param, :user_addon => @user_addon.attributes
    assert_redirected_to user_addon_path(assigns(:user_addon))
  end

  test "should destroy user_addon" do
    assert_difference('UserAddon.count', -1) do
      delete :destroy, :id => @user_addon.to_param
    end

    assert_redirected_to user_addons_path
  end
end
