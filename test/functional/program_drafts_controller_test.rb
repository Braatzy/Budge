require 'test_helper'

class ProgramDraftsControllerTest < ActionController::TestCase
  setup do
    @program_draft = program_drafts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:program_drafts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create program_draft" do
    assert_difference('ProgramDraft.count') do
      post :create, :program_draft => @program_draft.attributes
    end

    assert_redirected_to program_draft_path(assigns(:program_draft))
  end

  test "should show program_draft" do
    get :show, :id => @program_draft.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @program_draft.to_param
    assert_response :success
  end

  test "should update program_draft" do
    put :update, :id => @program_draft.to_param, :program_draft => @program_draft.attributes
    assert_redirected_to program_draft_path(assigns(:program_draft))
  end

  test "should destroy program_draft" do
    assert_difference('ProgramDraft.count', -1) do
      delete :destroy, :id => @program_draft.to_param
    end

    assert_redirected_to program_drafts_path
  end
end
