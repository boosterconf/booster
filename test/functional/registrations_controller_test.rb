require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  context "An admin" do

    setup do
      login_as :god
    end


    context "trying to delete a registration" do
      should "be able to" do

        assert_difference('Registration.count', -1) do
          delete :destroy, :id => registrations(:one).id, :name => "John H. Example", :confirmation => "joh"
        end

        assert_redirected_to registrations_path
      end


      should "get an error message and leave the registration untouched if confirmation does not match name" do
        assert_no_difference('Registration.count') do
          delete :destroy, :id => registrations(:one).id, :name => "John H. Example", :confirmation => "jjj"
        end

        assert_not_nil flash[:error]
      end

      should "delete all users talks too" do
        assert_difference('Talk.count', -1) do
          delete :destroy, :id => registrations(:six).id, :name => "John H. Example", :confirmation => "joh"
        end
      end

      should "not delete the talks of a user if the talk has several speakers" do
        assert_difference('Talk.count', -1) do
          delete :destroy, :id => registrations(:one).id, :name => "John H. Example", :confirmation => "joh"
        end
      end
    end

    context "updating other people's registrations" do
      should "trigger free registration email when a free registration is completed" do
        subject = registrations(:one)
        params = create_registration_params
        params["free_ticket"] = true

        assert_difference('ActionMailer::Base.deliveries.size', +1) do
          post :update, :registration => params, :id => subject.id
        end

        assert last_email_sent.subject.include?("free ticket"), "Subject '#{last_email_sent.subject}' did not include 'free ticket'"
      end
      
      should "trigger payment confirmation email when a non-free registration is completed" do
        subject = registrations(:one)

        assert_difference('ActionMailer::Base.deliveries.size', +1) do
          post :update, :registration => create_registration_params, :id => subject.id
        end

        assert last_email_sent.subject.include?("Payment"), "Subject '#{last_email_sent.subject}' did not include 'Payment'"
      end

      should "not trigger an email if the registration is not completed" do
        subject = registrations(:one)
        params = create_registration_params
        params["registration_complete"] = false

        assert_no_difference 'ActionMailer::Base.deliveries.size' do
          post :update, :registration => params, :id => subject.id
        end
      end
    end

  end

  context "An authenticated user" do
    setup do
      login_as :quentin
    end

    should "not be able to delete_registrations" do
      delete :destroy, :id => registrations(:one).id, :name => "John H. Example", :confirmation => "joh"
      assert_response 302
    end

    should "not be able to view confirm_delete" do
      get :confirm_delete, :id => registrations(:one).id
      assert_response 302
    end

    should "not receive an email when s/he updates own registration" do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post :update, :registration => create_registration_params, :id => registrations(:one).id
      end
    end
  end

  private
  def create_registration_params
    {"price"=>"6245", "includes_dinner" => true, "ticket_type_old" => "early_bird", "registration_complete" => true,
     "free_ticket" => false}
  end

  def last_email_sent
    ActionMailer::Base.deliveries.last
  end

end