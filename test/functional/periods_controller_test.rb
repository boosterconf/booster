require 'test_helper'

class PeriodsControllerTest < ActionController::TestCase

  def setup
    login_as :god
  end

  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:periods)
  end

  should "get new" do
    get :new
    assert_response :success
  end

  should "create period" do
    assert_difference('Period.count') do
      post :create, :period => { }
    end

    assert_redirected_to period_path(assigns(:period))
  end

  should "get edit" do
    get :edit, :id => periods(:one).to_param
    assert_response :success
  end

  should "update period" do
    put :update, :id => periods(:one).to_param, :period => { }
    assert_redirected_to period_path(assigns(:period))
  end

  should "destroy period" do
    assert_difference('Period.count', -1) do
      delete :destroy, :id => periods(:one).to_param
    end

    assert_redirected_to periods_path
  end
end
