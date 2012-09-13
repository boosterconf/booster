require 'test_helper'

class SponsorsControllerTest < ActionController::TestCase
  setup do
    @sponsor = sponsors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sponsors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sponsor" do
    assert_difference('Sponsor.count') do
      post :create, sponsor: { comment: @sponsor.comment, contact_person: @sponsor.contact_person, contact_person_phone: @sponsor.contact_person_phone, email: @sponsor.email, invoiced: @sponsor.invoiced, last_contacted_at: @sponsor.last_contacted_at, location: @sponsor.location, name: @sponsor.name, paid: @sponsor.paid, status: @sponsor.status, user_id: @sponsor.user_id, was_sponsor_last_year: @sponsor.was_sponsor_last_year }
    end

    assert_redirected_to sponsor_path(assigns(:sponsor))
  end

  test "should show sponsor" do
    get :show, id: @sponsor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sponsor
    assert_response :success
  end

  test "should update sponsor" do
    put :update, id: @sponsor, sponsor: { comment: @sponsor.comment, contact_person: @sponsor.contact_person, contact_person_phone: @sponsor.contact_person_phone, email: @sponsor.email, invoiced: @sponsor.invoiced, last_contacted_at: @sponsor.last_contacted_at, location: @sponsor.location, name: @sponsor.name, paid: @sponsor.paid, status: @sponsor.status, user_id: @sponsor.user_id, was_sponsor_last_year: @sponsor.was_sponsor_last_year }
    assert_redirected_to sponsor_path(assigns(:sponsor))
  end

  test "should destroy sponsor" do
    assert_difference('Sponsor.count', -1) do
      delete :destroy, id: @sponsor
    end

    assert_redirected_to sponsors_path
  end
end
