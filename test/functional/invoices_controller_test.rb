require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  setup do
    @invoice = invoices(:one)

    login_as :god
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoices)
  end

  test "should get new" do
    get :new
		assert_redirected_to edit_invoice_path(assigns(:invoice))
  end

  test "should create invoice" do
    assert_difference('Invoice.count') do
      post :create, invoice: create_invoice_params
    end

    assert_redirected_to invoice_path(assigns(:invoice))
  end

  test "should show invoice" do
    get :show, id: @invoice
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice
    assert_response :success
  end

  test "should update invoice" do
    put :update, id: @invoice, invoice: create_invoice_params
    assert_redirected_to invoice_path(assigns(:invoice))
  end

  def create_invoice_params
    { "email" => "a@b.no"}
  end

end
