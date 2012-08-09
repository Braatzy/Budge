require 'test_helper'

class FoursquareCategoriesControllerTest < ActionController::TestCase
  setup do
    @foursquare_category = foursquare_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:foursquare_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create foursquare_category" do
    assert_difference('FoursquareCategory.count') do
      post :create, :foursquare_category => @foursquare_category.attributes
    end

    assert_redirected_to foursquare_category_path(assigns(:foursquare_category))
  end

  test "should show foursquare_category" do
    get :show, :id => @foursquare_category.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @foursquare_category.to_param
    assert_response :success
  end

  test "should update foursquare_category" do
    put :update, :id => @foursquare_category.to_param, :foursquare_category => @foursquare_category.attributes
    assert_redirected_to foursquare_category_path(assigns(:foursquare_category))
  end

  test "should destroy foursquare_category" do
    assert_difference('FoursquareCategory.count', -1) do
      delete :destroy, :id => @foursquare_category.to_param
    end

    assert_redirected_to foursquare_categories_path
  end
end
