class TicketsController < ApplicationController
  before_action :require_admin, :only => [:index, :destroy, :edit, :update, :send_ticket_email, :download_emails]
  before_action :set_ticket, only: [:show, :edit, :update]
  before_action :ticket_sales_open?, only: [:new, :create]

  # GET /tickets
  def index
    @tickets = Ticket.all
    by_ticket_type = @tickets.group_by {|ticket| ticket.ticket_type.name}
    @stats = {}
    by_ticket_type.each_pair {|k, v| @stats[k] = v.count}
    @stats['Attending dinner'] = @tickets.where(attend_dinner: true).count
    @total_ticket_count = @tickets.count
  end

  def download_emails
    @tickets = Ticket.all

    respond_to do |format|
      format.html
      format.csv {send_data @tickets.to_csv, filename: "tickets-#{Date.today}.csv"}
    end
  end

  def send_ticket_email
    @tickets = Ticket.all

    @tickets.each {|ticket|
      if (!ticket.reference.present?)
        ticket.reference = SecureRandom.urlsafe_base64
        ticket.save!
        if ticket.email.present?
          BoosterMailer.send_ticket_link(ticket).deliver_now
        end
      end
    }
    flash[:notice] = "Eposter sendt."
    redirect_to tickets_path
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
      @ticket.attend_speakers_dinner = params[:ticket][:attend_speakers_dinner]
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
    if current_user && current_user.is_admin
      @ticket.ticket_type = TicketType.find_by_id(params[:ticket][:ticket_type_id])
    else
      @ticket.ticket_type = TicketType.current_normal_ticket
    end

    @payment_reference = params[:payment_reference]
    @payment_zip = params[:payment_zip_code]
    @ticket.roles = params[:roles].join(",") if params[:roles]
    @ticket.reference = SecureRandom.urlsafe_base64

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
        BoosterMailer.ticket_confirmation_invoice(@ticket).deliver_now
        if @ticket.ticket_type.paying_ticket?
          notice = "An invoice will be sent to #{@ticket.email}."
          BoosterMailer.invoice_to_fiken([@ticket], nil,
                                         {:payment_email => @ticket.email,
                                          :payment_info => @payment_reference,
                                          :payment_zip => @payment_zip,
                                          :extra_info => ""}).deliver_now
        end
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
    @ticket = Ticket.find_by(reference: params[:reference])
    @reference = params[:reference]
  end

  def create_from_reference
    unless params[:reference].present?
      flash[:notice] = "We could not find the tickets. Send an email to kontakt@boosterconf.no and we will fix it."
      redirect_to root_path
    end
    @ticket = Ticket.find_by(reference: params[:reference])
    @ticket.name = ticket_params[:name]
    @ticket.email = ticket_params[:email]
    @ticket.attend_dinner = ticket_params[:attend_dinner]
    @ticket.attend_speakers_dinner = ticket_params[:attend_speakers_dinner]
    @ticket.dietary_info = ticket_params[:dietary_info]
    @ticket.roles = params[:roles].join(",") if params[:roles]

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
    end

    @ticket.save!
    redirect_to @ticket
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ticket_params
    params.require(:ticket).permit(:name, :email, :feedback, :company,
                                   :attend_dinner, :attend_speakers_dinner, :dietary_info, :ticket_type_id, :reference)
  end

  def ticket_sales_open?
    if current_user && current_user.is_admin
      true
    else
      if AppConfig.ticket_sales_open
        return true
      end
      flash[:notice] = "Follow @boosterconf on Twitter to be notified when the next batch of tickets is available."
      redirect_to root_path
    end
  end
end
