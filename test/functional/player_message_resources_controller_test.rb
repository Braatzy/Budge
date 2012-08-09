require 'test_helper'

class PlayerMessageResourcesControllerTest < ActionController::TestCase
  setup do
    @player_message_resource = player_message_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:player_message_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create player_message_resource" do
    assert_difference('PlayerMessageResource.count') do
      post :create, :player_message_resource => @player_message_resource.attributes
    end

    assert_redirected_to player_message_resource_path(assigns(:player_message_resource))
  end

  test "should show player_message_resource" do
    get :show, :id => @player_message_resource.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @player_message_resource.to_param
    assert_response :success
  end

  test "should update player_message_resource" do
    put :update, :id => @player_message_resource.to_param, :player_message_resource => @player_message_resource.attributes
    assert_redirected_to player_message_resource_path(assigns(:player_message_resource))
  end

  test "should destroy player_message_resource" do
    assert_difference('PlayerMessageResource.count', -1) do
      delete :destroy, :id => @player_message_resource.to_param
    end

    assert_redirected_to player_message_resources_path
  end
end
