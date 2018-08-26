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
    @talk = talks(:three)
    get :accept, params: {id: @talk.id}
    assert_equal true, Talk.find(@talk.id).accepted?
  end

  def test_refuse_should_set_talk_as_refused
    @talk = talks(:three)
    get :refuse, params: {id: @talk.id}
    assert_equal true, Talk.find(@talk.id).refused?
  end
end
