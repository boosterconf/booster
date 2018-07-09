require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  context "An admin" do

    setup do
      login_as :god
    end


    context "trying to soft delete a registration" do
      should "be able to" do

        assert_difference('Registration.count', -1) do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example" }
        end

        assert_redirected_to registrations_path
      end

      should "only soft delete it" do

        assert_no_difference('Registration.with_deleted.count') do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example" }
        end

        assert_redirected_to registrations_path
      end

      should "also delete the user" do

        assert_difference('User.count', -1) do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example" }
        end

        assert_redirected_to registrations_path
      end

      should "only soft delete the user" do

        assert_no_difference('User.with_deleted.count') do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example" }
        end

        assert_redirected_to registrations_path
      end

      should "delete all users talks too" do
        assert_difference('Talk.count', -1) do
          delete :destroy, params: { id: registrations(:six).id, name: "John H. Example" }
        end
      end

      should "only soft delete all users talks" do
        assert_no_difference('Talk.with_deleted.count') do
          delete :destroy, params: { id: registrations(:six).id, name: "John H. Example" }
        end
      end

      should "not delete the talks of a user if the talk has several speakers" do
        assert_difference('Talk.count', -1) do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example" }
        end
      end
    end

    context "trying to really delete a registration" do
      should "not be able to if it hasn't been soft deleted" do

        assert_no_difference('Registration.with_deleted.count') do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example", really: true }
        end

        assert_redirected_to registrations_path
      end

      should "be able to if it has been soft deleted" do

        assert_difference('Registration.with_deleted.count', -1) do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example" }
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example", really: true }
        end

        assert_redirected_to deleted_registrations_path
      end

      should "also really delete the user" do

        assert_difference('User.with_deleted.count', -1) do
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example" }
          delete :destroy, params: { id: registrations(:one).id, name: "John H. Example", really: true }
        end

        assert_redirected_to deleted_registrations_path
      end
    end



    context "updating other people's registrations" do
      should "trigger free registration email when a free registration is completed" do
        subject = registrations(:one)
        params = create_registration_params
        params["free_ticket"] = true

        assert_difference('ActionMailer::Base.deliveries.size', +1) do
          post :update, params: { registration: params, id: subject.id }
        end

        assert last_email_sent.subject.include?("free ticket"), "Subject '#{last_email_sent.subject}' did not include 'free ticket'"
      end

      should "trigger payment confirmation email when a non-free registration is completed" do
        subject = registrations(:one)

        assert_difference('ActionMailer::Base.deliveries.size', +1) do
          post :update, params: { registration: create_registration_params, id: subject.id }
        end

        assert last_email_sent.subject.include?("Payment"), "Subject '#{last_email_sent.subject}' did not include 'Payment'"
      end

      should "not trigger an email if the registration is not completed" do
        subject = registrations(:one)
        params = create_registration_params
        params[:registration_complete] = false

        assert_no_difference 'ActionMailer::Base.deliveries.size' do
          post :update, params: { registration: params, id: subject.id }
        end
      end
    end

  end

  context "An authenticated user" do
    setup do
      login_as :quentin
    end

    should "not be able to delete_registrations" do
      delete :destroy, params: { id: registrations(:six).id, name: "John H. Example", confirmation: "joh" }
      assert_response 302
    end

    should "not receive an email when s/he updates own registration" do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post :update, params: { registration: create_registration_params, id: registrations(:one).id }
      end
    end
  end

  private
  def create_registration_params
    { ticket_type_id: ticket_types(:earlybird).id, registration_complete: true,
      free_ticket: false }
  end

end
