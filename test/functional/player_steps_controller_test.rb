require 'test_helper'

class PlayerStepsControllerTest < ActionController::TestCase
  setup do
    @player_step = player_steps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:player_steps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create player_step" do
    assert_difference('PlayerStep.count') do
      post :create, :player_step => @player_step.attributes
    end

    assert_redirected_to player_step_path(assigns(:player_step))
  end

  test "should show player_step" do
    get :show, :id => @player_step.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @player_step.to_param
    assert_response :success
  end

  test "should update player_step" do
    put :update, :id => @player_step.to_param, :player_step => @player_step.attributes
    assert_redirected_to player_step_path(assigns(:player_step))
  end

  test "should destroy player_step" do
    assert_difference('PlayerStep.count', -1) do
      delete :destroy, :id => @player_step.to_param
    end

    assert_redirected_to player_steps_path
  end
end
