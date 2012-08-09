require 'test_helper'

class LocationContextsControllerTest < ActionController::TestCase
  setup do
    @location_context = location_contexts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:location_contexts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location_context" do
    assert_difference('LocationContext.count') do
      post :create, :location_context => @location_context.attributes
    end

    assert_redirected_to location_context_path(assigns(:location_context))
  end

  test "should show location_context" do
    get :show, :id => @location_context.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @location_context.to_param
    assert_response :success
  end

  test "should update location_context" do
    put :update, :id => @location_context.to_param, :location_context => @location_context.attributes
    assert_redirected_to location_context_path(assigns(:location_context))
  end

  test "should destroy location_context" do
    assert_difference('LocationContext.count', -1) do
      delete :destroy, :id => @location_context.to_param
    end

    assert_redirected_to location_contexts_path
  end
end
