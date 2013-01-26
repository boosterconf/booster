require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  SOME_EMAIL = "a@b.no"

  context 'An unauthenticated user' do

    context 'creating a new user when early bird is still on' do

      setup do
        AppConfig.stubs(:early_bird_ends).returns(Time.now + 1.days)
        post :create, :user => create_user_params
        @registration = Registration.unscoped.order("id asc").last
      end

      should 'get an early bird ticket' do
        @registration.ticket_type_old = 'early_bird'
      end

    end

    context 'creating a new user after early bird is over' do

      setup do
        AppConfig.stubs(:early_bird_ends).returns(Time.now - 1.days)
        post :create, :user => create_user_params
        @registration = Registration.unscoped.order("id asc").last
      end

      should 'get a full price ticket' do
        @registration.ticket_type_old = 'full_price'
      end

    end

    should 'be able to create a new user' do
      post :create, :user => create_user_params
      assert_not_nil assigns :user
      assert_nil flash[:notice]
      assert_nil flash[:error]
    end

    context 'following an invalid user creation reference link' do
      setup do
        get :from_reference, :reference => "bogus"
      end

      should 'get an error message' do
        assert flash[:error] != nil
      end
    end

    context 'following a valid user creation link' do
      setup do

        @user = User.create_unfinished(SOME_EMAIL, "speaker")
        @user.save(:validate => false)

        kill_all_sessions # TODO: not sure why we have to do this, but we do.

        get :from_reference, :reference => @user.registration.unique_reference
      end

      should 'be redirected to user edit page' do
        assert_redirected_to edit_user_path @user
      end

      should 'be logged in as that user' do
        assert logged_in_user.email == @user.email
      end


    end

    context "trying to create a new user with limit for number of users reached" do
      setup do
        User.stubs(:count).returns(500)
        AppConfig.stubs(:max_users_limit).returns(500)
      end

      should "give an error message when create is called" do
        post :create, :user => create_user_params
        assert flash[:error]
      end

      should "give an error message when new is called" do
        get :new
        assert flash[:error]
      end
    end

    context 'trying to do a group registration' do

      context 'with one email only' do
        setup do
          @emails = "a@b.no"
        end

        should 'create a new user' do
          assert_difference('User.count' "+1") do
            assert_difference('Registration.count' "+1") do
              post :create_group_registration, :invoice => create_invoice_params, :emails => @emails
            end
          end
        end

        should 'create a new invoice' do
          assert_difference('Invoice.count' "+1") do
            post :create_group_registration, :invoice => create_invoice_params, :emails => @emails
          end
        end

        should 'add user to invoice' do
          post :create_group_registration, :invoice => create_invoice_params, :emails => @emails

          @registration = Registration.unscoped.order("id asc").last
          @invoice = Invoice.unscoped.order("id asc").last

          assert @invoice.registrations.include?(@registration)
        end

        context 'that is invalid' do
          setup do
            @emails = 'not really a valid email'
          end

          should 'be sent back to registration page' do
            post :create_group_registration, :invoice => create_invoice_params, :emails => @emails

            assert_template :group_registration
          end

          should 'not create an invoice' do
            assert_no_difference('Invoice.count') do
              post :create_group_registration, :invoice => create_invoice_params, :emails => @emails
            end
          end

          should 'not create a user' do
            assert_no_difference('User.count') do
              assert_no_difference('Registration.count') do
                post :create_group_registration, :invoice => create_invoice_params, :emails => @emails
              end
            end
          end
        end
      end

      context 'with three emails' do
        setup do
          @emails = "a@b.no,c@d.no; e@f.no"
        end

        should 'create three new users' do
          assert_difference('User.count', 3) do
            assert_difference('Registration.count', 3) do
              post :create_group_registration, :invoice => create_invoice_params, :emails => @emails
            end
          end
        end

        should 'create a new invoice' do
          assert_difference('Invoice.count', 1) do
            post :create_group_registration, :invoice => create_invoice_params, :emails => @emails
          end
        end

        should 'send out an email to each new user' do
          assert_difference('ActionMailer::Base.deliveries.size', +3) do
            post :create_group_registration, :invoice => create_invoice_params, :emails => @emails
          end
        end
      end
    end
  end

  context 'An unfinished user updating his profile info' do
    setup do
      @user = User.create_unfinished(SOME_EMAIL, "speaker")
      @user.save(:validate => false)

      post :update, :id => @user.id, :user => update_user_params
    end

    should 'no longer be unfinished' do
      registration = User.find_by_email(SOME_EMAIL).registration
      assert !registration.unfinished
    end
  end

  context 'A normal user' do
    setup do
      @normal_user = login_quentin
    end

    context 'that follows a valid user creation link' do
      setup do
        @user = User.create_unfinished("a@b.no", "speaker")
        @user.save(:validate => false)
        get :from_reference, :reference => @user.registration.unique_reference
      end

      should 'be redirected to profile page' do
        assert_redirected_to current_user_url
      end
    end

    should "not be able to create a bio" do

      @normal_user.registration = Registration.new
      @normal_user.registration.ticket_type_old = 'early_bird'
      @normal_user.registration.save
      assert @normal_user.id && @normal_user.registration.id
      post :create_bio, :id => @normal_user.id
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
    update_user_params.merge!({"email" => "test@mail.com"})
  end

  def update_user_params
    {"accepted_privacy_guidelines" => "1", "company" => "Test", "name" => "Test", "accept_optional_email" => "1",
     "password" => "fjasepass", "password_confirmation" => "fjasepass", "phone_number" => "92043382", "role" => "Developer", "birthyear" => 1984, "hometown" => "Bergen",
     "registration_attributes" => {"ticket_type_old" => "full_price", "manual_payment" => "", "free_ticket" => "false", "includes_dinner" => "1"}
    }
  end

  def create_speaker_params
    {"company" => "DRW", "name" => "Dan North", "bio_attributes" =>
        {"title" => "Boss", "blog" => "dannorth.net", "twitter_handle" => "tastapod", "bio" => "Testtest"},
     "gender" => "M", "password_confirmation" => "test", "role" => "Developer", "featured_speaker" => "0",
     "phone_number" => "93400346", "hometown" => "London", "registration_attributes" => {"includes_dinner" => "1"},
     "password" => "test", "birthyear" => "1976", "email" => "dan@north.net"}
  end

  def create_invoice_params
    {"your_reference" => "Karianne Berg", "email" => "karianne.berg@gmail.com"}
  end

  def login_quentin
    q = users(:quentin)
    UserSession.create(q)
    q
  end

  def kill_all_sessions
    session = UserSession.find
    session.destroy if session.present?
  end

end