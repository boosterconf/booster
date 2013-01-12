require 'test_helper'

class AcceptancesControllerTest < ActionController::TestCase

  def setup
    login_as(:god)
    @talk = talks(:three)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:talks)
  end

  def test_accept_should_set_talk_as_accepted
    get :accept, :id => @talk.id
    assert_equal true, Talk.find(@talk.id).accepted?
  end

  def test_accept_of_user_with_completed_registration_will_not_alter_ticket_type_old
    @talk = talks(:five)
    get :accept, :id => @talk.id
    assert_equal "sponsor", Registration.find(@talk.users[0].registration.id).ticket_type_old
  end

  def test_accept_of_lightning_talk_does_not_complete_registration_for_user
    @talk = talks(:five)
    get :accept, :id => @talk.id
    assert_equal false, Registration.find(@talk.users[0].registration.id).registration_complete?
  end

  def test_accept_of_tutorial_completes_registration_for_user
    @talk = talks(:nine)
    get :accept, :id => @talk.id

    assert_equal true, Registration.find(@talk.users[0].registration.id).registration_complete? # TODO: Fails
  end

  def test_refuse_should_set_talk_as_refused
    get :refuse, :id => @talk.id
    assert_equal true, Talk.find(@talk.id).refused?
  end

  def test_refuse_last_talk_sets_speakers_ticket_type_old_to_paying
    get :refuse, :id => @talk.id
    assert_equal "early_bird", Registration.find(@talk.users[0].registration.id).ticket_type_old
  end

  def test_refuse_talk_with_other_talks_pending_does_not_alter_speakers_ticket_type
    @talk = talks(:four)
    get :refuse, :id => @talk.id
    assert_equal "lightning", Registration.find(@talk.users[0].registration.id).ticket_type_old
  end

  def test_refusal_of_user_with_special_ticket_will_not_alter_ticket_type
    @talk = talks(:five)
    get :refuse, :id => @talk.id
    assert_equal "sponsor", Registration.find(@talk.users[0].registration.id).ticket_type_old
  end

  def test_refusal_of_tutorial_where_user_also_have_pending_lighting_talk_sets_ticket_type_to_lightning
    @talk = talks(:eight)
    #assert_equal "speaker", Registration.find(@talk.users[0].registration.id).ticket_type_old
    get :refuse, :id => @talk.id
    assert_equal "lightning", Registration.find(@talk.users[0].registration.id).ticket_type_old
  end

  def test_await_rolls_back_ticket_type_for_normal_users
    @talk = talks(:nine)
    assert_equal "early_bird", Registration.find(@talk.users[0].registration.id).ticket_type_old
    get :await, :id => @talk.id
    assert_equal "speaker", Registration.find(@talk.users[0].registration.id).ticket_type_old
    assert_equal false, Registration.find(@talk.users[0].registration.id).registration_complete
  end

  def test_await_does_not_roll_back_ticket_type_for_special_users
    @talk = talks(:five)
    assert_equal "sponsor", Registration.find(@talk.users[0].registration.id).ticket_type_old
    get :await, :id => @talk.id
    assert_equal "sponsor", Registration.find(@talk.users[0].registration.id).ticket_type_old
  end
end