require 'test_helper'

class VisitStatsControllerTest < ActionController::TestCase
  setup do
    @visit_stat = visit_stats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:visit_stats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create visit_stat" do
    assert_difference('VisitStat.count') do
      post :create, :visit_stat => @visit_stat.attributes
    end

    assert_redirected_to visit_stat_path(assigns(:visit_stat))
  end

  test "should show visit_stat" do
    get :show, :id => @visit_stat.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @visit_stat.to_param
    assert_response :success
  end

  test "should update visit_stat" do
    put :update, :id => @visit_stat.to_param, :visit_stat => @visit_stat.attributes
    assert_redirected_to visit_stat_path(assigns(:visit_stat))
  end

  test "should destroy visit_stat" do
    assert_difference('VisitStat.count', -1) do
      delete :destroy, :id => @visit_stat.to_param
    end

    assert_redirected_to visit_stats_path
  end
end
