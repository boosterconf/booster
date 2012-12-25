require 'test_helper'

class TutorialRegistrationControllerTest < ActionController::TestCase

=begin
  context "An unauthenticated user" do
    should "not be able to view index" do
      get :index
      assert_response 302
    end
  end

  context "An authenticated user" do

    setup do
      login_as :quentin
    end

    should "be able to view index" do
      get :index
      assert_response 200
    end

    should "be able to register for a tutorial" do
      assert_difference('Participant.count', +1) do
        post :update, :talks => create_tutorial_params
      end
    end

    should "not get additional participations when s/he updates participance" do
      post :update, :talks => create_tutorial_params

      assert_no_difference('Participant.count') do
        post :update, :talks => create_tutorial_params
      end
    end

    context "registering for a tutorial that spans several slots" do

      should "not insert duplicates of the same talk" do
        post :update, :talks => create_tutorial_params

        assert_no_difference('Participant.count') do
          talk = talks(:spans_several_slots)
          post :update, :talks => {periods(:one).id.to_s => talk.id.to_s, periods(:two).id.to_s => talk.id.to_s}
        end
      end

      should "prefer the talk selected in the first of the periods if the talks chosen overlap" do
        assert_difference('Participant.count', +1) do
          post :update, :talks => {periods(:one).id.to_s => talks(:spans_several_slots).id.to_s, periods(:two).id.to_s => talks(:not_full_tutorial).id.to_s}
        end

        assert_equal talks(:spans_several_slots), Participant.find_all_by_user_id(users(:quentin).id).first.talk
      end

    end

    context "trying to register for a full tutorial" do

      should "not be able to register for it" do
        Talk.any_instance.stubs(:is_full? => true)
        assert_no_difference('Participant.count') do
          post :update, :talks => create_tutorial_params
        end
      end

      should "give an error message" do
        Talk.any_instance.stubs(:is_full? => true)
        post :update, :talks => create_tutorial_params
        assert flash[:error]
      end

      should "keep old participation in same period" do
        post :update, :talks => create_tutorial_params(talks(:two))
        assert_nil flash[:error]
        Talk.any_instance.stubs(:is_full? => true)

        assert_no_difference('Participant.count') do
          post :update, :talks => create_tutorial_params
        end
      end
    end

    context "trying to register a tutorial participance when tutorial registration is closed" do

      setup do
        AppConfig.stubs(:tutorial_registration_open).returns(false)
      end

      should "get an error message when trying to access index" do
        get :index

        assert flash[:error]
      end

      should "get an error message when trying to update participation" do
        post :update, :talks => create_tutorial_params

        assert flash[:error]
      end

    end
  end

  context "An admin" do

    setup do
      login_as :god
    end

    context "trying to register a tutorial participance when tutorial registration is closed" do

      setup do
        AppConfig.stubs(:tutorial_registration_open).returns(false)
      end

      should "be allowed to to access index" do
        get :index

        assert_response 200
        assert_nil flash[:error]
      end

      should "be allowed to update participation" do
        post :update, :talks => create_tutorial_params

        assert_response 302
        assert_nil flash[:error]
      end

    end
  end
=end

  private
  def create_tutorial_params(talk = talks(:ten), period = periods(:one))
    {period.id.to_s => talk.id.to_s}
  end

end
