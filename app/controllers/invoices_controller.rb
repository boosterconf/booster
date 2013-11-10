class InvoicesController < ApplicationController

  respond_to :html

  before_filter :require_admin
  before_filter :find_invoice, only: [:update, :edit, :show]

  def index
    @invoices = Invoice.all

    respond_with @invoices
  end

  def show
    respond_with @invoice
  end

  def new
    @invoice = Invoice.new

    respond_with @invoice
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
    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully updated.'
    else
      render action: :new
    end
  end

  private
  def find_invoice
    @invoice = Invoice.find(params[:id])
  end
end
