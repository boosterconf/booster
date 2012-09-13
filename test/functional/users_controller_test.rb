require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { accept_optional_email: @user.accept_optional_email, accepted_privacy_guidelines: @user.accepted_privacy_guidelines, birthyear: @user.birthyear, company: @user.company, crypted_password: @user.crypted_password, current_login_at: @user.current_login_at, current_login_ip: @user.current_login_ip, description: @user.description, dietary_requirements: @user.dietary_requirements, email: @user.email, failed_login_count: @user.failed_login_count, feature_as_organizer: @user.feature_as_organizer, featured_speaker: @user.featured_speaker, female: @user.female, hometown: @user.hometown, invited: @user.invited, is_admin: @user.is_admin, last_login_at: @user.last_login_at, last_request_at: @user.last_request_at, login_count: @user.login_count, member_dnd: @user.member_dnd, name: @user.name, password_salt: @user.password_salt, perishable_token: @user.perishable_token, persistence_token: @user.persistence_token, phone_number: @user.phone_number, registration_ip: @user.registration_ip, role: @user.role }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { accept_optional_email: @user.accept_optional_email, accepted_privacy_guidelines: @user.accepted_privacy_guidelines, birthyear: @user.birthyear, company: @user.company, crypted_password: @user.crypted_password, current_login_at: @user.current_login_at, current_login_ip: @user.current_login_ip, description: @user.description, dietary_requirements: @user.dietary_requirements, email: @user.email, failed_login_count: @user.failed_login_count, feature_as_organizer: @user.feature_as_organizer, featured_speaker: @user.featured_speaker, female: @user.female, hometown: @user.hometown, invited: @user.invited, is_admin: @user.is_admin, last_login_at: @user.last_login_at, last_request_at: @user.last_request_at, login_count: @user.login_count, member_dnd: @user.member_dnd, name: @user.name, password_salt: @user.password_salt, perishable_token: @user.perishable_token, persistence_token: @user.persistence_token, phone_number: @user.phone_number, registration_ip: @user.registration_ip, role: @user.role }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
