require 'test_helper'

class ProgramPlayersControllerTest < ActionController::TestCase
  setup do
    @program_player = program_players(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:program_players)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create program_player" do
    assert_difference('ProgramPlayer.count') do
      post :create, :program_player => @program_player.attributes
    end

    assert_redirected_to program_player_path(assigns(:program_player))
  end

  test "should show program_player" do
    get :show, :id => @program_player.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @program_player.to_param
    assert_response :success
  end

  test "should update program_player" do
    put :update, :id => @program_player.to_param, :program_player => @program_player.attributes
    assert_redirected_to program_player_path(assigns(:program_player))
  end

  test "should destroy program_player" do
    assert_difference('ProgramPlayer.count', -1) do
      delete :destroy, :id => @program_player.to_param
    end

    assert_redirected_to program_players_path
  end
end
