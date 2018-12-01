require 'test_helper'

class InviteesControllerTest < ActionController::TestCase

  def setup
    login_as :god
  end

=begin
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invitees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invitee" do
    assert_difference('Invitee.count') do
      post :create, :invitee => { }
    end

    assert_redirected_to invitee_path(assigns(:invitee))
  end

  test "should show invitee" do
    get :show, :id => invitees(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => invitees(:one).to_param
    assert_response :success
  end

  test "should update invitee" do
    put :update, :id => invitees(:one).to_param, :invitee => { }
    assert_redirected_to invitee_path(assigns(:invitee))
  end

  test "should destroy invitee" do
    assert_difference('Invitee.count', -1) do
      delete :destroy, :id => invitees(:one).to_param
    end

    assert_redirected_to invitees_path
  end
=end
end
