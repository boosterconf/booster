class TicketsController < ApplicationController
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

  # GET /tickets/1/edit
  def edit
  end

  # POST /tickets
  def create
    @ticket = Ticket.new(ticket_params)
    #Optionally, we might allow user to choose ticket type.
    @ticket.ticket_type = TicketType.current_normal_ticket
    @ticket.roles = params[:roles].join(",") if params[:roles]

    puts @ticket.inspect

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
      # We might consider storing the charge id on the ticket perhaps? Or on an invoice of sorts.
    else
      puts "Create an invoice instead"
    end

    if @ticket.save
      #Send email.
      redirect_to @ticket, notice: 'Ticket was successfully created.'
    else
      render :new
    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_ticket_path

  end

  # PATCH/PUT /tickets/1
  def update
    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: 'Ticket was successfully updated.'
    else
      render :edit
    end
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
