class InvoicesController < ApplicationController

  respond_to :html

  before_filter :require_admin
  before_filter :find_invoice, only: [:update, :edit, :show, :add_user, :remove_user, :invoiced, :paid]
  before_filter :find_users_without_invoice

  def index
    @invoices = Invoice.order("invoiced_at desc", "created_at asc").all

    respond_with @invoices
  end

  def show
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
      render action: :edit
    end
  end

  def add_user
    user = User.find(params[:user_id])
    if user.registration.invoice_line
      head :bad_request
    else
      invoice_line = @invoice.add_user(user)

      render json: invoice_line.to_json
    end

  end

  def remove_line
    InvoiceLine.find(params[:invoice_line_id]).destroy

    render json: {
               id: params[:invoice_line_id]
           }
  end

  def invoiced
    @invoice.invoice!
    @invoice.save

    redirect_to action: :index
  end

  def paid
    @invoice.pay!
    @invoice.save

    redirect_to action: :index
  end

  private
  def find_invoice
    @invoice = Invoice.find(params[:id])
  end

  def find_users_without_invoice
    @users = Registration.includes(:invoice_line)
                 .where(invoice_lines: { registration_id: nil })
                 .where("ticket_type_old IN (?)", Registration::PAYING_TICKET_TYPES)
                 .map(&:user).reject(&:nil?).map { |u| ["#{u.name_or_email} - #{u.company}", u.id]}
  end
end
