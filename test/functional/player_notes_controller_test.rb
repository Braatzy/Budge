require 'test_helper'

class PlayerNotesControllerTest < ActionController::TestCase
  setup do
    @player_note = player_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:player_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create player_note" do
    assert_difference('PlayerNote.count') do
      post :create, :player_note => @player_note.attributes
    end

    assert_redirected_to player_note_path(assigns(:player_note))
  end

  test "should show player_note" do
    get :show, :id => @player_note.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @player_note.to_param
    assert_response :success
  end

  test "should update player_note" do
    put :update, :id => @player_note.to_param, :player_note => @player_note.attributes
    assert_redirected_to player_note_path(assigns(:player_note))
  end

  test "should destroy player_note" do
    assert_difference('PlayerNote.count', -1) do
      delete :destroy, :id => @player_note.to_param
    end

    assert_redirected_to player_notes_path
  end
end
