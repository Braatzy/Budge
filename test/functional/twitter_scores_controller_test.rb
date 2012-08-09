require 'test_helper'

class TwitterScoresControllerTest < ActionController::TestCase
  setup do
    @twitter_score = twitter_scores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_score" do
    assert_difference('TwitterScore.count') do
      post :create, :twitter_score => @twitter_score.attributes
    end

    assert_redirected_to twitter_score_path(assigns(:twitter_score))
  end

  test "should show twitter_score" do
    get :show, :id => @twitter_score.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @twitter_score.to_param
    assert_response :success
  end

  test "should update twitter_score" do
    put :update, :id => @twitter_score.to_param, :twitter_score => @twitter_score.attributes
    assert_redirected_to twitter_score_path(assigns(:twitter_score))
  end

  test "should destroy twitter_score" do
    assert_difference('TwitterScore.count', -1) do
      delete :destroy, :id => @twitter_score.to_param
    end

    assert_redirected_to twitter_scores_path
  end
end
