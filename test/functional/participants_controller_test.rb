require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase

  def setup
    login_as :god
  end

=begin
  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:talks)
  end

  should "should get new" do
    get :new
    assert_response :success
  end

  should "should create participant" do
    assert_difference('Participant.count') do
      post :create, :participant => {}
    end

    assert_redirected_to participants_path
  end

  should "should destroy participant" do
    assert_difference('Participant.count', -1) do
      delete :destroy, :id => participants(:god_participates_at_talk_two).to_param
    end

    assert_redirected_to participants_path
  end
=end
end
