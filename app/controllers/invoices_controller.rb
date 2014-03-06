class InvoicesController < ApplicationController

  respond_to :html

  before_filter :require_admin
  before_filter :find_invoice, only: [:update, :edit, :show, :add_user, :remove_user]

  def index
    @invoices = Invoice.order(:created_at).all()

    respond_with @invoices
  end

  def show
    @invoice.registrations = Registration.where(invoice_id: params[:id])

    respond_with @invoice
  end

  def new
    @invoice = Invoice.new
    if @invoice.save
      redirect_to edit_invoice_url(@invoice), notice: 'Invoice was successfully created.'
    end
  end

  def edit

  end

  def create
    @invoice = Invoice.new(params[:invoice])

    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully created.'
    else
      render action: :new
    end
  end

  def update
    if @invoice.update_attributes(params[:invoice])
      redirect_to @invoice, notice: 'Invoice was successfully updated.'
    else
      flash.now[:error] = 'Unable to update invoice'
      render :action => "edit"
    end
  end

  def add_user
    registration = User.find(params[:user_id]).registration
    registration.invoice_id = @invoice.id
    registration.save

    render :json => {
        :id => registration.user.id,
        :name => registration.user.name,
        :email => registration.user.email,
        :ticket_type_old => registration.ticket_type_old,
        :price => registration.price
    }
  end

  def remove_user
    registration = User.find(params[:user_id]).registration
    registration.invoice_id = nil
    registration.save

    render :json => {
        :id => registration.user.id
    }
  end

  private
  def find_invoice
    @invoice = Invoice.find(params[:id])
  end
end
