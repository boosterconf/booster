class TicketsController < ApplicationController
  before_filter :require_admin, :only => [:index, :destroy,:edit, :update]
  before_action :set_ticket, only: [:show, :edit, :update]

  # GET /tickets
  def index
    @tickets = Ticket.all
    by_ticket_type = @tickets.group_by {|ticket| ticket.ticket_type.name}
    @stats = {}
    by_ticket_type.each_pair {|k, v| @stats[k] = v.count }
    @stats['Attending dinner'] = @tickets.count {|ticket| ticket.attend_dinner }
  end

  # GET /tickets/1
  def show
  end

  # GET /tickets/1
  def edit
  end

  # POST /tickets/1
  def update
    @ticket = Ticket.find(params[:id])
    if @ticket.valid?
      if params[:ticket_change]
        @ticket.ticket_type = TicketType.find_by_id(params[:ticket][:ticket_type_id])
      end
      @ticket.name = params[:ticket][:name]
      @ticket.company = params[:ticket][:company]
      @ticket.attend_dinner = params[:ticket][:attend_dinner]
      @ticket.dietary_info = params[:ticket][:dietary_info]
      @ticket.save
      flash[:notice] = "Information updated"
      redirect_to '/tickets'
    else
      flash.now[:error] = 'Unable to update ticket'
      render :action => "edit"
    end
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
    @ticket.ticket_type = TicketType.current_normal_ticket
  end

  # POST /tickets
  def create
    @ticket = Ticket.new(ticket_params)
    @payment_reference = params[:payment_reference]
    @payment_zip = params[:payment_zip_code]
    #Optionally, we might allow user to choose ticket type.
    @ticket.ticket_type = TicketType.current_normal_ticket
    @ticket.roles = params[:roles].join(",") if params[:roles]

    unless @ticket.valid?
      render :new
    else
      # Avoiding duplicate registrations
      if Ticket.has_ticket(@ticket.email)
        existing_ticket = Ticket.where(email: @ticket.email).take
        redirect_to existing_ticket, notice: "You are registered for Booster!" and return
      end

      if (params[:stripeToken])
        puts "Received stripe token, pay with card"
        customer = Stripe::Customer.create(
            :email => params[:stripeEmail],
            :source => params[:stripeToken]
        )

        charge = Stripe::Charge.create(
            :customer => customer.id,
            :amount => (@ticket.ticket_type.price_with_vat * 100).to_int,
            :description => @ticket.ticket_type.name,
            :statement_descriptor => @ticket.ticket_type.name.slice(0, ([@ticket.ticket_type.name.length, 22].min)),
            :currency => 'nok'
        )
        notice = "Your ticket is paid for!"
        BoosterMailer.ticket_confirmation_paid(@ticket).deliver_now
        BoosterMailer.invoice_to_fiken([@ticket], charge, nil).deliver_now
      else
        puts "Send an invoice instead"
        notice = "An invoice will be sent to #{@ticket.email}."
        BoosterMailer.ticket_confirmation_invoice(@ticket).deliver_now
        BoosterMailer.invoice_to_fiken([@ticket], nil,
                                        {   :payment_email => @ticket.email,
                                            :payment_info => @payment_reference,
                                            :payment_zip => @payment_zip,
                                            :extra_info => ""}).deliver_now
      end
      @ticket.save!
      redirect_to @ticket, notice: notice
    end

  rescue Stripe::CardError => e
    flash[:stripe_error] = e.message
    render :new
  rescue Stripe::RateLimitError => e
    puts e
    flash[:stripe_error] = "We were unable to process your payment via Stripe. Don't worry, choose invoice instead, and we'll sort it out."
    redirect_to new_ticket_path
  rescue Stripe::InvalidRequestError => e
    puts e
    flash[:stripe_error] = "We were unable to process your payment via Stripe. Don't worry, choose invoice instead, and we'll sort it out."
    redirect_to new_ticket_path
  rescue Stripe::AuthenticationError => e
    puts e
    flash[:stripe_error] = "We were unable to process your payment via Stripe. Don't worry, choose invoice instead, and we'll sort it out."
    redirect_to new_ticket_path
  rescue Stripe::APIConnectionError => e
    puts e
    flash[:stripe_error] = "We were unable to process your payment via Stripe. Don't worry, choose invoice instead, and we'll sort it out."
    redirect_to new_ticket_path
  rescue Stripe::StripeError => e
    puts e
    flash[:stripe_error] = "We were unable to process your payment via Stripe. Don't worry, choose invoice instead, and we'll sort it out."
    redirect_to new_ticket_path
  rescue => e
    puts e
    flash[:error] = "Something went wrong and I don't know what to do about it. I need to tell my human, so they can figure it out. Come back later."
    render :new
  end

  # DELETE /tickets/1
  def destroy
    Ticket.delete(params[:id])
    redirect_to tickets_url, notice: 'Ticket was successfully destroyed.'
  end

  def from_reference
    @ticket = Ticket.includes(:ticket_types).where(reference: params[:reference]).to_a.first
    puts "Found ticket ? " + @ticket.present?
    puts @ticket.inspect
    @sponsor = Sponsor.all_accepted.where(name: @ticket.company).to_a.first
    @reference = params[:reference]

    rescue
      flash[:notice] = "We could not find the tickets. Send an email to kontakt@boosterconf.no and we will fix it."
      redirect_to root_path
  end

  def create_from_reference
    unless params[:reference].present?
      flash[:notice] = "We could not find the tickets. Send an email to kontakt@boosterconf.no and we will fix it."
      redirect_to root_path
    end
    @ticket = Ticket.includes(:ticket_types).where(reference: params[:reference]).to_a.first
    puts @ticket
    @sponsor = Sponsor.all_accepted.where(name: @ticket.company).to_a.first
    @ticket.name = params[:ticket][name]
    @ticket.email = params[:ticket][email]
    @ticket.attend_dinner = params[:ticket][attend_dinner]
    @ticket.roles = params[:roles].join(",") if params[:roles]
    @ticket.dietary_info = params[:ticket][dietary_info]
    @ticket.save!
    render action: 'show'

  rescue => e
    puts e
    flash[:error] = e.message
    @reference = params[:reference]
    render action: 'from_reference'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ticket_params
    params.require(:ticket).permit(:name, :email, :feedback, :company,
                                   :attend_dinner, :dietary_info)
  end

end