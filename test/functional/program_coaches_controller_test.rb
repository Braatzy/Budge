require 'test_helper'

class ProgramCoachesControllerTest < ActionController::TestCase
  setup do
    @program_coach = program_coaches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:program_coaches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create program_coach" do
    assert_difference('ProgramCoach.count') do
      post :create, :program_coach => @program_coach.attributes
    end

    assert_redirected_to program_coach_path(assigns(:program_coach))
  end

  test "should show program_coach" do
    get :show, :id => @program_coach.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @program_coach.to_param
    assert_response :success
  end

  test "should update program_coach" do
    put :update, :id => @program_coach.to_param, :program_coach => @program_coach.attributes
    assert_redirected_to program_coach_path(assigns(:program_coach))
  end

  test "should destroy program_coach" do
    assert_difference('ProgramCoach.count', -1) do
      delete :destroy, :id => @program_coach.to_param
    end

    assert_redirected_to program_coaches_path
  end
end
