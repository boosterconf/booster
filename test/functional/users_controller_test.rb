require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def create_user_params
    {"accepted_privacy_guidelines"=>"1", "company"=>"Test", "name"=>"Test", "accept_optional_email"=>"1",
     "password" =>"fjasepass", "password_confirmation"=>"fjasepass", "phone_number"=>"92043382", "role" => "Developer", "birthyear" => 1984, "hometown" => "Bergen",
     "registration_attributes" => {"ticket_type_old"=>"full_price", "manual_payment"=>"", "free_ticket"=>"false", "includes_dinner"=>"1"},
     "email" =>"test@mail.com"}
  end

  def create_speaker_params
    {"company"=>"DRW", "name"=>"Dan North", "bio_attributes"=>
        {"title"=>"Boss", "blog"=>"dannorth.net", "twitter_handle"=>"tastapod", "bio"=>"Testtest"},
     "female"=>"false", "password_confirmation"=>"test", "role"=>"Developer", "featured_speaker"=>"0",
     "phone_number"=>"93400346", "hometown"=>"London", "registration_attributes"=>{"includes_dinner"=>"1"},
     "password"=>"test", "birthyear"=>"1976", "email"=>"dan@north.net"}
  end

  def login_quentin
    q = users(:quentin)
    UserSession.create(q)
    q
  end

  context 'UsersController' do
    should "be able to create user" do
      post :create, :user=> create_user_params()
      assert assign_to :user
      assert_nil flash[:notice]
      assert_nil flash[:error]
    end

    should "have special fields when ticket_type is set" do
      get :new, :free_ticket=> 'sponsor'
      assert_nil flash[:error]
      assert_select "select[name='user[registration_attributes][ticket_type_old]']"
    end

    context "with limit for number of user reached" do

      setup do
        User.stubs(:count).returns(500)
        AppConfig.stubs(:max_users_limit).returns(500)
      end

      should "give an error message when create is called" do
        post :create, :user=> create_user_params()
        assert flash[:error]
      end

      should "give an error message when new is called" do
        get :new
        assert flash[:error]
      end
    end

    context "with existing user" do
      should "be able to change dinner attendance" do
        q = login_quentin
        assert !q.attending_dinner?
        get :attending_dinner
        assert flash[:notice]
        assert_redirected_to current_users_path
      end
      context "when logged in as admin" do
        should "be able to create bio" do
          god = users(:god)
          UserSession.create(god)
          post :create_bio, :id => users(:quentin).id
          assert_response 200
        end
        should "be able to delete bio" do
          god = users(:god)
          UserSession.create(god)
          q = users(:quentin)
          bio = Bio.new(:title => "test")
          User.update(q, {:bio => bio})
          post :delete_bio, :id => q.id
          assert_response 302
          assert q.bio.nil?
        end
      end
      should "only allow admin and speakers to create bio" do
        q = login_quentin
        q.registration = Registration.new
        q.registration.ticket_type_old = 'early_bird'
        q.registration.save
        assert q.id && q.registration.id
        post :create_bio, :id => q.id
        assert_response 302
      end
      should "allow speakers to create/edit bio" do
        q = login_quentin
        q.registration = Registration.new
        q.registration.ticket_type_old = 'speaker'
        q.registration.save
        assert q.id && q.registration.id
        post :create_bio, :id => q.id
        assert_response 200
      end
    end

    context "register invited speaker" do
      should "deny unauthorized user" do
        login_quentin
        get :speaker
        assert_response 302
      end

      should "allow admin to view registration form" do
        login_as(:god)
        get :speaker
        assert_response :success
      end

      should "create speaker" do
        login_as(:god)
        post :create_speaker, :user=> create_speaker_params
        assert_response 302
        user = User.find_by_email('dan@north.net')
        assert_not_nil user.registration
        assert_not_nil user.bio
        assert_nil flash[:notice]
        assert_nil flash[:error]
      end
    end

  end


end
