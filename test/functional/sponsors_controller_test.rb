require 'test_helper'

class SponsorsControllerTest < ActionController::TestCase

  context "An admin" do

    setup do
      login_as :god
    end

    should "be able to view index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:sponsors)
    end

    should "be able to show new form" do
      get :new
      assert_response :success
    end

    should "be able to create new sponsor" do
      assert_difference('Sponsor.count', +1) do
        post :create, :sponsor => valid_sponsor_params
      end

      assert_redirected_to sponsors_path
    end

    should "be able to show edit form" do
      get :edit, :id => sponsors(:one).to_param
      assert_response :success
    end

    should "be able to update sponsor" do
      put :update, id: sponsors(:one).to_param, sponsor: valid_sponsor_params
      assert_redirected_to sponsors_path
    end

    should "be able to delete a sponsor" do
      assert_difference('Sponsor.count', -1) do
        delete :destroy, :id => sponsors(:one).to_param
      end

      assert_redirected_to sponsors_path
    end
  end

  private
  def valid_sponsor_params
    { sponsor: { email: "a@b.no"} }
  end
end