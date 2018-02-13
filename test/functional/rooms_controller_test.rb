require 'test_helper'

class RoomsControllerTest < ActionController::TestCase
  setup do
    @room = rooms(:one)
    login_as(:god)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rooms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create room" do
    assert_difference('Room.count') do
      post :create, params: { room: { capacity: @room.capacity, name: @room.name } }
    end

    assert_redirected_to rooms_path
  end

  test "should show room" do
    get :show, params: { id: @room }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @room }
    assert_response :success
  end

  test "should update room" do
    put :update, params: { id: @room, room: { capacity: @room.capacity, name: @room.name } }
    assert_redirected_to room_path(assigns(:room))
  end

  test "should destroy room" do
    assert_difference('Room.count', -1) do
      delete :destroy, params: { id: @room }
    end

    assert_redirected_to rooms_path
  end
end
