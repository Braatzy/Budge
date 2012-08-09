require 'test_helper'

class ProgramBudgeTemplatesControllerTest < ActionController::TestCase
  setup do
    @program_budge_template = program_budge_templates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:program_budge_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create program_budge_template" do
    assert_difference('ProgramBudgeTemplate.count') do
      post :create, :program_budge_template => @program_budge_template.attributes
    end

    assert_redirected_to program_budge_template_path(assigns(:program_budge_template))
  end

  test "should show program_budge_template" do
    get :show, :id => @program_budge_template.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @program_budge_template.to_param
    assert_response :success
  end

  test "should update program_budge_template" do
    put :update, :id => @program_budge_template.to_param, :program_budge_template => @program_budge_template.attributes
    assert_redirected_to program_budge_template_path(assigns(:program_budge_template))
  end

  test "should destroy program_budge_template" do
    assert_difference('ProgramBudgeTemplate.count', -1) do
      delete :destroy, :id => @program_budge_template.to_param
    end

    assert_redirected_to program_budge_templates_path
  end
end
