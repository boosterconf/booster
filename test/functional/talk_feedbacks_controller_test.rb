require 'test_helper'

class TalkFeedbacksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:talk_feedbacks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create talk_feedback" do
    assert_difference('TalkFeedback.count') do
      post :create, :talk_feedback => { }
    end

    assert_redirected_to talk_feedback_path(assigns(:talk_feedback))
  end

  test "should show talk_feedback" do
    get :show, :id => talk_feedbacks(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => talk_feedbacks(:one).to_param
    assert_response :success
  end

  test "should update talk_feedback" do
    put :update, :id => talk_feedbacks(:one).to_param, :talk_feedback => { }
    assert_redirected_to talk_feedback_path(assigns(:talk_feedback))
  end

  test "should destroy talk_feedback" do
    assert_difference('TalkFeedback.count', -1) do
      delete :destroy, :id => talk_feedbacks(:one).to_param
    end

    assert_redirected_to talk_feedbacks_path
  end
end
