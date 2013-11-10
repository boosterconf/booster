class InvoicesController < ApplicationController

  respond_to :html

  before_filter :require_admin

  def index
    @invoices = Invoice.all

    respond_with @invoices
  end

  def show
    @invoice = Invoice.find(params[:id])

    respond_with @invoice
  end

  def new
    @invoice = Invoice.new

    respond_with @invoice
  end

  def edit
    @invoice = Invoice.find(params[:id])
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
    @invoice = Invoice.find(params[:id])

    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully updated.'
    else
      render action: :new
    end
  end

end
