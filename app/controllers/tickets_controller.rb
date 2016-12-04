class TicketsController < ApplicationController
  before_filter :require_admin, :only => [:index, :destroy]
  before_action :set_ticket, only: [:show, :edit, :update]

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
    @payment_reference = params[:payment_reference]
    @payment_zip = params[:payment_zip_code]
    #Optionally, we might allow user to choose ticket type.
    @ticket.ticket_type = TicketType.current_normal_ticket
    @ticket.roles = params[:roles].join(",") if params[:roles]

    unless @ticket.valid?
      render :new
    else
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
        BoosterMailer.invoice_to_fiken(generate_invoice_pdf([@ticket], charge, nil)).deliver_now
      else
        puts "Send an invoice instead"
        notice = "An invoice will be sent to #{@ticket.email}."
        BoosterMailer.ticket_confirmation_invoice(@ticket).deliver_now
        BoosterMailer.invoice_to_fiken(generate_invoice_pdf([@ticket], nil,
                                                            {   :payment_email => @ticket.email,
                                                                :payment_info => @payment_reference,
                                                                :payment_zip => @payment_zip})
                      ).deliver_now
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

  def generate_invoice_pdf(tickets, stripe_charge, invoice_details)
    Prawn::Document.generate('invoice_details.pdf', :page_size => 'A4') do
      font "Courier"
      pad(20) {
        text "Invoice details Booster #{Dates::CONFERENCE_YEAR} tickets",
             :size => 20 }
      stroke_horizontal_rule
      if stripe_charge
        pad_top(20) { text "Stripe payment:".ljust(20) + "#{stripe_charge.id}" }
        pad_bottom(20) { text "Payment status:".ljust(20) + "#{stripe_charge.paid ? 'Paid' : 'Payment failed'}" }
      else
        pad_top(20) { text "Invoice reference:".ljust(20) + "#{invoice_details[:payment_info]}" }
        text "Invoice ZIP:".ljust(20) + "#{invoice_details[:payment_zip]}"
        pad_bottom(20) { text "Send to:".ljust(20) + "#{invoice_details[:payment_email]}" }
      end
      stroke_horizontal_rule
      font
      pad_top(20) { text "Description".ljust(35) + "VAT".ljust(15) + "Amount".ljust(15), :style => :bold }
      pad_bottom(20) { stroke_horizontal_rule }
      tickets.each { |ticket|
        text ticket.ticket_type.name.ljust(35) + "#{ticket.ticket_type.vat} NOK".ljust(15) + "#{ticket.ticket_type.price} NOK".ljust(15)
      }
      pad_top(20) { stroke_horizontal_rule }
      total = tickets.inject(0) { |sum, t| sum + t.ticket_type.price_with_vat }
      pad(20) { text 'Total (incl. VAT)'.ljust(35) + ''.ljust(15) + "#{total} NOK".ljust(15), :style => :bold }
    end
  end
end
