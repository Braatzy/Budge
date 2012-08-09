require 'test_helper'

class AddonsControllerTest < ActionController::TestCase
  setup do
    @addon = addons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:addons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create addon" do
    assert_difference('Addon.count') do
      post :create, :addon => @addon.attributes
    end

    assert_redirected_to addon_path(assigns(:addon))
  end

  test "should show addon" do
    get :show, :id => @addon.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @addon.to_param
    assert_response :success
  end

  test "should update addon" do
    put :update, :id => @addon.to_param, :addon => @addon.attributes
    assert_redirected_to addon_path(assigns(:addon))
  end

  test "should destroy addon" do
    assert_difference('Addon.count', -1) do
      delete :destroy, :id => @addon.to_param
    end

    assert_redirected_to addons_path
  end
end
