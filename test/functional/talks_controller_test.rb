require 'test_helper'

class TalksControllerTest < ActionController::TestCase

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:talks)
  end

  def test_should_show_talk
    get :show, :id => talks(:one).id
    assert_response :success
  end

  def test_should_get_edit
    login_as :quentin
    get :edit, :id => talks(:one).id
    assert_response :success
  end

  def test_should_update_talk
    login_as :quentin
    put :update, :id => talks(:one).id, :talk => {}
    assert_redirected_to talk_path(assigns(:talk))
  end

  def test_should_destroy_talk
    login_as :quentin
    assert_difference('Talk.count', -1) do
      delete :destroy, :id => talks(:one).id
    end

    assert_redirected_to talks_path
  end

  def test_users_cannot_update_other_peoples_talks
    login_as :other
    put :update, :id => talks(:one).id, :talk => {}
    assert_response 302
  end

  def test_admins_can_update_talks
    login_as :god
    put :update, :id => talks(:one).id, :talk => {}
    assert_redirected_to talk_path(assigns(:talk))
  end

  context "An admin" do

    setup do
      login_as :god
    end

  end

  private
  def create_valid_talk_params
    {"audience_level"=>"novice", "title"=>"Assigned", "talk_type_id"=>"4", "language"=>"English", "accepted_guidelines"=>"1", "max_participants"=>"999", "description"=>"<p>test</p>"}
  end

  def create_invalid_talk_params
    {"audience_level"=>"novice", "title"=>"Assigned", "talk_type_id"=>"4", "accepted_guidelines"=>"1", "max_participants"=>"999", "description"=>"<p>test</p>"}
  end
end
