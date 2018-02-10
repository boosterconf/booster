require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  SOME_EMAIL = 'a@b.no'

  context 'An unauthenticated user' do

    context 'creating a new user when early bird is still on' do

      setup do
        AppConfig.stubs(:early_bird_ends).returns(Time.now + 1.days)
        post :create, :user => create_user_params
        @registration = Registration.unscoped.order("id asc").last
      end

      should 'get an early bird ticket' do
        assert @registration.ticket_type.reference = 'early_bird'
      end

    end

    context 'creating a new user after early bird is over' do

      setup do
        AppConfig.stubs(:early_bird_ends).returns(Time.now - 1.days)
        post :create, :user => create_user_params
        @registration = Registration.unscoped.order("id asc").last
      end

      should 'get a full price ticket' do
        assert @registration.ticket_type.reference = 'full_price'
      end

    end

    should 'be able to create a new user' do
      assert_difference 'User.count', +1 do
        post :create, :user => create_user_params
      end
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

        @user = User.create_unfinished(SOME_EMAIL, TicketType.speaker)
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
  end

  context 'An unfinished user updating his profile info' do
    setup do
      @user = User.create_unfinished(SOME_EMAIL, TicketType.speaker)
      @user.save(:validate => false)
    end

    should 'no longer be unfinished' do
      post :update, :id => @user.id, :user => update_user_params

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
        @user = User.create_unfinished("a@b.no", TicketType.speaker)
        @user.save(:validate => false)
        get :from_reference, :reference => @user.registration.unique_reference
      end

      should 'be redirected to profile page' do
        assert_redirected_to current_user_url
      end
    end
  end

  context 'A speaker' do
    should 'be allowed to create/edit own bio' do

      login_as :multispeaker

      post :create_bio, id: users(:multispeaker).id
      assert_response 200
    end
  end

  context 'An administrator' do
    setup do
      login_as :god
    end

    should 'be able to create bio' do
      assert_difference 'Bio.count', +1 do
        post :create_bio, id: users(:singlespeaker).id
      end

      assert_response 200
    end

    should 'be able to delete bio' do
      q = users(:quentin)
      bio = Bio.new(title: 'test')
      User.update(q.id, { bio: bio })

      post :delete_bio, :id => q.id

      assert_response 302
      assert q.bio.nil?
    end

    context 'registering an invited speaker' do
      setup do
        @invited_speaker_params = create_user_params.merge!({ invited: true })
      end

      should 'not send an email' do
        assert_no_difference('ActionMailer::Base.deliveries.size') do
          post :create, user: @invited_speaker_params
        end
      end

    end
  end

  private
  def create_user_params
    update_user_params.merge!({ 'email' => 'test@mail.com' })
  end

  def update_user_params
    { 'accepted_privacy_guidelines' => '1', 'company' => 'Test', 'first_name' => 'Test', 'last_name' => 'Osteron', 'accept_optional_email' => '1',
      'password' => 'fjasepass', 'password_confirmation' => 'fjasepass', 'phone_number' => '92043382', 'birthyear' => 1984, 'hometown' => 'Bergen',
      'registration_attributes' => { 'includes_dinner' => "1" }
    }
  end

  def create_speaker_params
    { 'company' => 'DRW', 'first_name' => 'Dan', 'last_name' => 'North', 'bio_attributes' =>
        { 'title' => 'Boss', 'blog' => 'dannorth.net', 'twitter_handle' => 'tastapod', 'bio' => 'Testtest' },
      'gender' => 'M', 'password_confirmation' => 'test', 'featured_speaker' => '0',
      'phone_number' => '93400346', 'hometown' => 'London', 'registration_attributes' => { 'includes_dinner' => '1' },
      'password' => 'test', 'birthyear' => '1976', 'email' => 'dan@north.net' }
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