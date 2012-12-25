require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context 'An unauthenticated user' do
    should 'be able to create a new user' do
      post :create, :user => create_user_params
      assert_not_nil assigns :user
      assert_nil flash[:notice]
      assert_nil flash[:error]
    end

    context "with limit for number of user reached" do
      setup do
        User.stubs(:count).returns(500)
        AppConfig.stubs(:max_users_limit).returns(500)
      end

      should "give an error message when create is called" do
        post :create, :user => create_user_params()
        assert flash[:error]
      end

      should "give an error message when new is called" do
        get :new
        assert flash[:error]
      end
    end
  end

  context 'A normal user' do
    setup do
      @q = login_quentin
    end

    should "not be able to create a bio" do

      @q.registration = Registration.new
      @q.registration.ticket_type_old = 'early_bird'
      @q.registration.save
      assert @q.id && @q.registration.id
      post :create_bio, :id => @q.id
      assert_response 302
    end
  end

  context "A speaker" do
    should "be allowed to create/edit own bio" do
      q = login_quentin
      q.registration = Registration.new
      q.registration.ticket_type_old = 'speaker'
      q.registration.save
      assert q.id && q.registration.id
      post :create_bio, :id => q.id
      assert_response 200
    end
  end

  context "An administrator" do
    setup do
      login_as :god
    end

    should "be able to create bio" do
      post :create_bio, :id => users(:quentin).id
      assert_response 200
    end

    should "be able to delete bio" do
      q = users(:quentin)
      bio = Bio.new(:title => "test")
      User.update(q, {:bio => bio})
      post :delete_bio, :id => q.id
      assert_response 302
      assert q.bio.nil?
    end
  end


  private
  def create_user_params
    {"accepted_privacy_guidelines" => "1", "company" => "Test", "name" => "Test", "accept_optional_email" => "1",
     "password" => "fjasepass", "password_confirmation" => "fjasepass", "phone_number" => "92043382", "role" => "Developer", "birthyear" => 1984, "hometown" => "Bergen",
     "registration_attributes" => {"ticket_type_old" => "full_price", "manual_payment" => "", "free_ticket" => "false", "includes_dinner" => "1"},
     "email" => "test@mail.com"}
  end

  def create_speaker_params
    {"company" => "DRW", "name" => "Dan North", "bio_attributes" =>
        {"title" => "Boss", "blog" => "dannorth.net", "twitter_handle" => "tastapod", "bio" => "Testtest"},
     "gender" => "M", "password_confirmation" => "test", "role" => "Developer", "featured_speaker" => "0",
     "phone_number" => "93400346", "hometown" => "London", "registration_attributes" => {"includes_dinner" => "1"},
     "password" => "test", "birthyear" => "1976", "email" => "dan@north.net"}
  end

  def login_quentin
    q = users(:quentin)
    UserSession.create(q)
    q
  end

end
