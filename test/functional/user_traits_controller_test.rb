require 'test_helper'

class UserTraitsControllerTest < ActionController::TestCase
  setup do
    @user_trait = user_traits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_traits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_trait" do
    assert_difference('UserTrait.count') do
      post :create, :user_trait => @user_trait.attributes
    end

    assert_redirected_to user_trait_path(assigns(:user_trait))
  end

  test "should show user_trait" do
    get :show, :id => @user_trait.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user_trait.to_param
    assert_response :success
  end

  test "should update user_trait" do
    put :update, :id => @user_trait.to_param, :user_trait => @user_trait.attributes
    assert_redirected_to user_trait_path(assigns(:user_trait))
  end

  test "should destroy user_trait" do
    assert_difference('UserTrait.count', -1) do
      delete :destroy, :id => @user_trait.to_param
    end

    assert_redirected_to user_traits_path
  end
end
