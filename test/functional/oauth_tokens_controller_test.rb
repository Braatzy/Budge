require 'test_helper'

class OauthTokensControllerTest < ActionController::TestCase
  setup do
    current_user = users(:one)
    @oauth_token = oauth_tokens(:facebook)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:oauth_tokens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create oauth_token" do
    assert_difference('OauthToken.count') do
      post :create, :oauth_token => @oauth_token.attributes
    end

    assert_redirected_to oauth_token_path(assigns(:oauth_token))
  end

  test "should show oauth_token" do
    get :show, :id => @oauth_token.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @oauth_token.to_param
    assert_response :success
  end

  test "should update oauth_token" do
    put :update, :id => @oauth_token.to_param, :oauth_token => @oauth_token.attributes
    assert_redirected_to oauth_token_path(assigns(:oauth_token))
  end

  test "should destroy oauth_token" do
    assert_difference('OauthToken.count', -1) do
      delete :destroy, :id => @oauth_token.to_param
    end

    assert_redirected_to oauth_tokens_path
  end
end
