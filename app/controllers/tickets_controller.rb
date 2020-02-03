class TicketsController < ApplicationController
  before_action :require_admin, :only => [:index, :destroy, :edit, :update, :send_ticket_email, :download_emails]
  before_action :set_ticket, only: [:show, :edit, :update]
  before_action :ticket_sales_open?, only: [:new, :create]

  @@filter_params = [:sponsor_id]
  # GET /tickets
  def index
    @tickets = Ticket.includes(:ticket_type).all
    @stats = build_ticket_stats(@tickets)
    @filters = {}
    if(params[:sponsor_id])
      @filters[:sponsor_id] = params[:sponsor_id].to_i
    end
    @filtered_tickets = filter_tickets(@tickets, @filters)
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
    #@ticket = Ticket.new
    @ticket_order_form = TicketOrderForm.new
    @ticket_type = TicketType.current_normal_ticket
    @ticket_order_form.ticket_type_reference = @ticket_type.reference
    #@ticket.ticket_type = TicketType.current_normal_ticket
  end

  # POST /tickets
  def create
    ActiveRecord::Base.transaction do

      @ticket_order_form = TicketOrderForm.new(ticket_form_params)
      @ticket_type = TicketType.find_by_reference(@ticket_order_form.ticket_type_reference) || TicketType.current_normal_ticket

      unless @ticket_order_form.valid?
        render :new
      else

        if(@ticket_order_form.attendees.count > 1)
          throw StandardError.new("We are not designed for more attendees on this flow")
        end
        attendee = @ticket_order_form.attendees.first
        @ticket = Ticket.from_attendee_form(attendee)
        if current_user && current_user.is_admin
          @ticket.ticket_type = TicketType.find_by_reference(@ticket_order_form.ticket_type_reference)
        else
          @ticket.ticket_type = TicketType.current_normal_ticket
        end

        @ticket.roles = attendee.roles.join(",")
        @ticket.reference = SecureRandom.urlsafe_base64


        unless @ticket.valid?
          render :new, notice: "Could not generate ticket from your info, please contact us!"
        else

          payment_type = @ticket_order_form.payment_details_type
          if(["card", "invoice"].include?(payment_type))

            order = Order.new
            order.tickets << @ticket
            order.payment_type = @ticket_order_form.payment_details_type
            order.save!
            if(payment_type == "card")
              redirect_to new_order_direct_payment_path(order)
            elsif(payment_type == "invoice")
              invoice_details = @ticket_order_form.invoice_details
              FikenOrderInvoiceCreationJob.perform_later(order.id, invoice_details.name, invoice_details.email, params[:payment_reference])
              BoosterMailer.ticket_confirmation_invoice(@ticket).deliver_later
              redirect_to order_path(order)
            end

          else
            @ticket.save!
            BoosterMailer.ticket_confirmation_company_invoice(@ticket).deliver_later
            BoosterMailer.ticket_company_invoice_details(@ticket, @ticket_order_form.company_invoice_details.name).deliver_later
            redirect_to ticket_path(@ticket)
          end

        end
      end
    end
  end

  # DELETE /tickets/1
  def destroy
    Ticket.destroy(params[:id])
    if(params[:filter])
      filters = params[:filters].permit(@@filter_params)
    else
      filters = {}
    end
    redirect_to tickets_url(filters), notice: 'Ticket was successfully destroyed.'
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

  def ticket_form_params
    params.require(:ticket_order_form).permit!
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

  def filter_tickets(tickets, filters)
    filtered_tickets = tickets
    if(filters[:sponsor_id])
      filtered_tickets = SponsorTicket.where(sponsor_id: filters[:sponsor_id]).includes(:ticket).map(&:ticket)
    end
    return filtered_tickets
  end

  def build_ticket_stats(tickets)
    stats = {}

    by_ticket_type = tickets.group_by {|ticket| ticket.ticket_type.name}
    by_ticket_type.each_pair {|k, v| stats[k] = v.count}

    stats['Attending dinner'] = tickets.select { |t| t.attend_dinner == true }.count
    stats['Total'] = tickets.count

    return stats
  end
end
