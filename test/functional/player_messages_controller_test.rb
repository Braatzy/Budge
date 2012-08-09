require 'test_helper'

class PlayerMessagesControllerTest < ActionController::TestCase
  setup do
    @player_message = player_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:player_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create player_message" do
    assert_difference('PlayerMessage.count') do
      post :create, :player_message => @player_message.attributes
    end

    assert_redirected_to player_message_path(assigns(:player_message))
  end

  test "should show player_message" do
    get :show, :id => @player_message.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @player_message.to_param
    assert_response :success
  end

  test "should update player_message" do
    put :update, :id => @player_message.to_param, :player_message => @player_message.attributes
    assert_redirected_to player_message_path(assigns(:player_message))
  end

  test "should destroy player_message" do
    assert_difference('PlayerMessage.count', -1) do
      delete :destroy, :id => @player_message.to_param
    end

    assert_redirected_to player_messages_path
  end
end
