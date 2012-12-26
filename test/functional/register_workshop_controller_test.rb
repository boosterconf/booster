require 'test_helper'

class RegisterWorkshopControllerTest < ActionController::TestCase

  EMAIL = "a@b.no"
  TITLE = "hest"

  context "An authenticated user" do
    setup do
      login_as :quentin
    end

    context "creating a talk" do

      should "not create a new user when no additional speaker is given" do
        assert_no_difference('User.count') do
          assert_no_difference('Registration.count') do
            post :create_talk, :talk => create_talk_params
          end
        end
      end

      should "create a new user when additional speaker is given" do
        assert_difference('User.count' "+1") do
          assert_difference('Registration.count' "+1") do
            post :create_talk, :talk => create_talk_params, :user => {:additional_speaker_email => EMAIL}
          end
        end
      end

      should 'when a user with given email already exists should not create a new user' do
        assert_no_difference('User.count') do
          assert_no_difference('Registration.count') do
            post :create_talk, :talk => create_talk_params, :user => {:additional_speaker_email => users(:quentin).email}
          end
        end
      end

      should 'when a user with given email already exists should send an email to us' do
          assert_difference('ActionMailer::Base.deliveries.size', +1) do
            post :create_talk, :talk => create_talk_params, :user => {:additional_speaker_email => users(:quentin).email}
          end
      end

      context "create a new user" do
        setup do
          post :create_talk, :talk => create_talk_params, :user => {:additional_speaker_email => EMAIL}
          @registration = Registration.unscoped.order("id asc").last
          @user = User.unscoped.order("id asc").last
        end

        should "with a random unique reference" do
          assert_not_nil @registration.unique_reference
        end

        should "that gets an email" do
          assert last_email_sent[:to] = EMAIL
        end

        should "marked as unfinished" do
          assert_true @registration.unfinished
        end

        should "have email set" do
          assert @user.email == EMAIL
        end

        should "be a speaker on the talk" do
          assert @user.talks.first.title == TITLE
        end
      end
    end
  end

  private
  def create_talk_params
    {
        "talk_type_id" => talk_types(:tutorial).id,
        "title" => TITLE,
        "description" => "<p>ponni</p>",
        "max_participants" => "20",
        "participant_requirements" => "Nothing",
        "equipment" => "Stables and hay"
    }
  end

end