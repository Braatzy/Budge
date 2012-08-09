require 'test_helper'

class StreamItemsControllerTest < ActionController::TestCase
  setup do
    @stream_item = stream_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_item" do
    assert_difference('StreamItem.count') do
      post :create, :stream_item => @stream_item.attributes
    end

    assert_redirected_to stream_item_path(assigns(:stream_item))
  end

  test "should show stream_item" do
    get :show, :id => @stream_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stream_item.to_param
    assert_response :success
  end

  test "should update stream_item" do
    put :update, :id => @stream_item.to_param, :stream_item => @stream_item.attributes
    assert_redirected_to stream_item_path(assigns(:stream_item))
  end

  test "should destroy stream_item" do
    assert_difference('StreamItem.count', -1) do
      delete :destroy, :id => @stream_item.to_param
    end

    assert_redirected_to stream_items_path
  end
end
