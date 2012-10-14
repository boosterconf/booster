require 'test_helper'

class SlotsControllerTest < ActionController::TestCase

  def setup
    login_as :god
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:periods)
  end

  test "should get new" do
    get :new
    assert_not_nil assigns(:talks)
    assert_not_nil assigns(:periods)
    assert_response :success
  end

  test "should create slot" do
    assert_difference('Slot.count') do
      post :create, :slot => { }
    end

    assert_redirected_to slot_path(assigns(:slot))
  end

  test "should show slot" do
    get :show, :id => slots(:one).to_param
    assert_response :success
  end

  test "should destroy slot" do
    assert_difference('Slot.count', -1) do
      delete :destroy, :id => slots(:one).to_param
    end

    assert_redirected_to slots_path
  end
end
