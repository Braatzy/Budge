require 'test_helper'

class ProgramLinkResourcesControllerTest < ActionController::TestCase
  setup do
    @program_link_resource = program_link_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:program_link_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create program_link_resource" do
    assert_difference('ProgramLinkResource.count') do
      post :create, :program_link_resource => @program_link_resource.attributes
    end

    assert_redirected_to program_link_resource_path(assigns(:program_link_resource))
  end

  test "should show program_link_resource" do
    get :show, :id => @program_link_resource.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @program_link_resource.to_param
    assert_response :success
  end

  test "should update program_link_resource" do
    put :update, :id => @program_link_resource.to_param, :program_link_resource => @program_link_resource.attributes
    assert_redirected_to program_link_resource_path(assigns(:program_link_resource))
  end

  test "should destroy program_link_resource" do
    assert_difference('ProgramLinkResource.count', -1) do
      delete :destroy, :id => @program_link_resource.to_param
    end

    assert_redirected_to program_link_resources_path
  end
end
