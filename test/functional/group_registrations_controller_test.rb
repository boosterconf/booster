require 'test_helper'

class GroupRegistrationsControllerTest < ActionController::TestCase
  context 'with one email only' do
    setup do
      @emails = 'a@b.no'
    end

    should 'create a new user' do
      assert_difference('User.count' '+1') do
        assert_difference('Registration.count' '+1') do
          post :create, invoice: create_invoice_params, emails: @emails
        end
      end
    end

    should 'create a new invoice' do
      assert_difference('Invoice.count' '+1') do
        post :create, invoice: create_invoice_params, emails: @emails
      end
    end

    should 'add user to invoice' do
      post :create, invoice: create_invoice_params, emails: @emails

      @registration = Registration.unscoped.order("id asc").last
      @invoice = Invoice.unscoped.order("id asc").last

      assert @invoice.registrations.include?(@registration)
    end

    context 'that is invalid' do
      setup do
        @emails = 'not really a valid email'
      end

      should 'be sent back to registration page' do
        post :create, invoice: create_invoice_params, emails: @emails

        assert_template :group_registration
      end

      should 'not create an invoice' do
        assert_no_difference('Invoice.count') do
          post :create, invoice: create_invoice_params, emails: @emails
        end
      end

      should 'not create a user' do
        assert_no_difference('User.count') do
          assert_no_difference('Registration.count') do
            post :create, :invoice => create_invoice_params, :emails => @emails
          end
        end
      end
    end
  end

  context 'with three emails' do
    setup do
      @emails = 'a@b.no,c@d.no; e@f.no'
    end

    should 'create three new users' do
      assert_difference('User.count', 3) do
        assert_difference('Registration.count', 3) do
          post :create, :invoice => create_invoice_params, :emails => @emails
        end
      end
    end

    should 'create one new invoice' do
      assert_difference('Invoice.count', +1) do
        post :create, :invoice => create_invoice_params, :emails => @emails
      end
    end

    should 'send out an email to each new user' do
      assert_difference('ActionMailer::Base.deliveries.size', +3) do
        post :create, :invoice => create_invoice_params, :emails => @emails
      end
    end
  end

  private
  def create_invoice_params
    { 'your_reference' => 'Karianne Berg', 'email' => 'karianne.berg@gmail.com' }
  end

end
