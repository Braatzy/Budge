require 'test_helper'

class LinkResourcesControllerTest < ActionController::TestCase
  setup do
    @link_resource = link_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:link_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create link_resource" do
    assert_difference('LinkResource.count') do
      post :create, :link_resource => @link_resource.attributes
    end

    assert_redirected_to link_resource_path(assigns(:link_resource))
  end

  test "should show link_resource" do
    get :show, :id => @link_resource.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @link_resource.to_param
    assert_response :success
  end

  test "should update link_resource" do
    put :update, :id => @link_resource.to_param, :link_resource => @link_resource.attributes
    assert_redirected_to link_resource_path(assigns(:link_resource))
  end

  test "should destroy link_resource" do
    assert_difference('LinkResource.count', -1) do
      delete :destroy, :id => @link_resource.to_param
    end

    assert_redirected_to link_resources_path
  end
end
