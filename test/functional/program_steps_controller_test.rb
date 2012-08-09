require 'test_helper'

class ProgramStepsControllerTest < ActionController::TestCase
  setup do
    @program_step = program_steps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:program_steps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create program_step" do
    assert_difference('ProgramStep.count') do
      post :create, :program_step => @program_step.attributes
    end

    assert_redirected_to program_step_path(assigns(:program_step))
  end

  test "should show program_step" do
    get :show, :id => @program_step.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @program_step.to_param
    assert_response :success
  end

  test "should update program_step" do
    put :update, :id => @program_step.to_param, :program_step => @program_step.attributes
    assert_redirected_to program_step_path(assigns(:program_step))
  end

  test "should destroy program_step" do
    assert_difference('ProgramStep.count', -1) do
      delete :destroy, :id => @program_step.to_param
    end

    assert_redirected_to program_steps_path
  end
end
