require 'test_helper'

class PackTraitsControllerTest < ActionController::TestCase
  setup do
    @pack_trait = pack_traits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pack_traits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pack_trait" do
    assert_difference('PackTrait.count') do
      post :create, :pack_trait => @pack_trait.attributes
    end

    assert_redirected_to pack_trait_path(assigns(:pack_trait))
  end

  test "should show pack_trait" do
    get :show, :id => @pack_trait.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @pack_trait.to_param
    assert_response :success
  end

  test "should update pack_trait" do
    put :update, :id => @pack_trait.to_param, :pack_trait => @pack_trait.attributes
    assert_redirected_to pack_trait_path(assigns(:pack_trait))
  end

  test "should destroy pack_trait" do
    assert_difference('PackTrait.count', -1) do
      delete :destroy, :id => @pack_trait.to_param
    end

    assert_redirected_to pack_traits_path
  end
end
