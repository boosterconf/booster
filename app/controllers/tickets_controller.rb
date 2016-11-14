class TicketsController < ApplicationController
  before_filter :require_admin, :only => [:index, :destroy]
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

  # GET /tickets
  def index
    @tickets = Ticket.all
  end

  # GET /tickets/1
  def show
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
    @ticket.ticket_type = TicketType.current_normal_ticket
  end

  # POST /tickets
  def create
    @ticket = Ticket.new(ticket_params)
    #Optionally, we might allow user to choose ticket type.
    @ticket.ticket_type = TicketType.current_normal_ticket
    @ticket.roles = params[:roles].join(",") if params[:roles]

    unless @ticket.save
      render :new
    else
      if (params[:stripeToken])
        puts "Received stripe token, pay with card"
        customer = Stripe::Customer.create(
            :email => params[:stripeEmail],
            :source  => params[:stripeToken]
        )

        charge = Stripe::Charge.create(
            :customer    => customer.id,
            :amount      => (@ticket.ticket_type.price_with_vat * 100).to_int,
            :description => @ticket.ticket_type.name,
            :currency    => 'nok'
        )
        Invoice.create_stripe_payment(@ticket, charge)
        notice = "Your ticket is paid for!"
        BoosterMailer.ticket_confirmation_paid(@ticket).deliver_now
      else
        puts "Create an invoice instead"
        Invoice.create_ticket_invoice(@ticket, params[:payment_info], params[:payment_zip])
        notice = "An invoice will be sent to #{@ticket.email}."
        BoosterMailer.ticket_confirmation_invoice(@ticket).deliver_now
      end

      redirect_to @ticket, notice: notice
    end

    rescue Stripe::CardError => e
      flash[:stripe_error] = e.message
      redirect_to new_ticket_path

  end

  # DELETE /tickets/1
  def destroy
    @ticket.destroy
    redirect_to tickets_url, notice: 'Ticket was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def ticket_params
      params.require(:ticket).permit(:name, :email, :feedback, :company,
                                     :attend_dinner, :dietary_info, :gender)
    end
end
