class SponsorsController < ApplicationController

  before_action :require_admin
  before_action :find_sponsor, only: [:update, :destroy, :email]
  before_action :find_sponsors, only: [:index, :update]
  before_action :find_events_and_stats, only: [:index, :update]

  respond_to :html, :js

  def index
    @users = User.all_organizers
  end

  def new
    @users = User.all_organizers
    @sponsor = Sponsor.new
  end

  def edit
    @users = User.all_organizers
    @sponsor = Sponsor.includes(:events).find(params[:id])

    @event = Event.new(sponsor: @sponsor)
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)

    if @sponsor.save
      redirect_to sponsors_path, notice: 'Partner was successfully created.'
    else
      render action: :new
    end
  end

  def update
    @users = User.all_organizers
    @sponsor =
        SponsorAcceptedSlackNotifier.new(
            SponsorInvoiceCreator.new(
                SponsorStatusEventCreator.new(
                    user: current_user, sponsor: SponsorTicketCreator.new(
                                          Sponsor.find(params[:id])
                                      )
                )
            )
        )
    @sponsor.assign_attributes(sponsor_params)

    User.transaction do
      Sponsor.transaction do

        Rails.cache.delete(Cache::PartnerCacheKey)

        respond_to do |format|
          format.html {
            if @sponsor.save
              redirect_to sponsors_path, notice: "Partner #{@sponsor.name} was successfully updated."
            else
              @event = Event.new(sponsor_id: @sponsor.id)
              render action: :edit
            end
          }

          format.js {
	    notice = "I have no idea what just happened." #obvs should not actually ever happen..
	    if params[:sponsor].has_key?(:user_id)
	      unless @sponsor.user.nil?
	        notice = "Responsible for #{@sponsor.name} changed to #{@sponsor.user.full_name}"
	      else
	        notice = "Nobody is responsible for #{@sponsor.name} anymore."
	      end
	    elsif params[:sponsor].has_key?(:status)
	      notice = "Status for #{@sponsor.name} changed to #{Sponsor::STATES[@sponsor.status]}"
	    end

	    if @sponsor.save
              flash[:notice] = notice
            else
              flash[:error] = "#{@sponsor.name} was NOT updated!"
	    end
            render
          }
        end
      end
    end
  end

  def destroy
    @users = User.all_organizers
    @sponsor.destroy

    redirect_to sponsors_url, notice: "Partner #{@sponsor.name} was deleted."
  end

  def email
    @users = User.all_organizers
    if @sponsor.is_ready_for_email?
      Sponsor.transaction do
        BoosterMailer.initial_sponsor_mail(@sponsor).deliver_now
        @sponsor.status = 'contacted'
        @sponsor.last_contacted_at = Time.now.to_datetime
        @sponsor.save

        event = Event.new(:user => current_user, :sponsor => @sponsor, :comment => "Email sent to #{@sponsor.contact_person_name} (#{@sponsor.email})")
        event.save
      end

      redirect_to(sponsors_path, :notice => "Email sent to #{@sponsor.name} (#{@sponsor.contact_person_name} #{@sponsor.email}) and partner status set to 'Contacted'.")
    else
      flash[:error] = 'No email sent: must have status suggested and responsible set'
      redirect_to sponsors_path
    end
  end

  def email_tickets
    sponsors = Sponsor.all_accepted
    sponsors.each { |sponsor|
      create_tickets_for(sponsor)

    }
    redirect_to sponsors_url, notice: "Emails with partner ticket registration links was sent."
  end

  def ajax_email
    @users = User.all_organizers
    if @sponsor.is_ready_for_email?
      BoosterMailer.initial_sponsor_mail(@sponsor).deliver_now
      @sponsor.status = 'contacted'
      @sponsor.last_contacted_at = Time.now.to_datetime
      if @sponsor.save
        event = Event.new(:user => current_user, :sponsor => @sponsor, :comment => "Email sent to #{@sponsor.contact_person_name} (#{@sponsor.email})")
        event.save

        redirect_to(sponsors_path, :notice => "Email was sent to #{@sponsor.name} ((#{@sponsor.contact_person_name} #{@sponsor.email}) and partner status set to 'Contacted'.")
      else
        redirect_to sponsors_path
      end
    else
      flash[:error] = 'No email sent: must have status suggested and responsible set'
      redirect_to sponsors_path
    end
  end

  private
  def sponsor_params
    params.require(:sponsor).permit(:comment, :contact_person_first_name, :contact_person_last_name, :contact_person_phone_number,
                                    :email, :last_contacted_at, :location, :name, :status, :user_id,
                                    :was_sponsor_last_year, :events, :logo, :publish_logo, :website)
  end

  def find_sponsor
    @sponsor = Sponsor.find(params[:id])
  end

  def find_sponsors
    @sponsors = Sponsor.includes(:user).order(:name).to_a
  end

  def find_events_and_stats
    @number_of_sponsors_per_user = @sponsors.group_by(&:user).map { |user, sponsors| [user != nil ? user.full_name : "(none)", sponsors.length] }.sort { |a, b| a[1] <=> b[1] }.reverse!
    @stats = {
        'Accepted' => Sponsor.where(status: 'accepted').count,
        'Declined' => Sponsor.where(status: 'declined').count,
        'In dialogue' => Sponsor.where(status: 'dialogue').count,
        'Suggested (with email)' => Sponsor.where(status: 'suggested').where.not(email: '').count,
        'Suggested (missing email)' => Sponsor.where(status: 'suggested', email: '').count,
        'Contacted' => Sponsor.where(status: 'contacted').count,
        'Reminded' => Sponsor.where(status: 'reminded').count,
        'Don\'t ask' => Sponsor.where(status: 'never').count,
        'Both years' => Sponsor.where(status: 'accepted', was_sponsor_last_year: true).count,
        'New this year' => Sponsor.where(status: 'accepted', was_sponsor_last_year: false).count
    }

    @events = Event.first(15)
  end

  NUMBER_OF_TICKETS_PER_SPONSOR = 2
  def create_tickets_for(sponsor)
    existing_ticket_count = Ticket.joins(:ticket_type).where(:company => sponsor.name, :ticket_type => TicketType.sponsor).count
    puts existing_ticket_count
    if existing_ticket_count < NUMBER_OF_TICKETS_PER_SPONSOR
      tickets = []
      (NUMBER_OF_TICKETS_PER_SPONSOR - existing_ticket_count).times do
        ticket = Ticket.new
        ticket.ticket_type = TicketType.sponsor
        ticket.company = sponsor.name
        ticket.name = ""
        ticket.email = ""
        ticket.reference = SecureRandom.urlsafe_base64
        ticket.save!
        tickets.push ticket
      end
      BoosterMailer.send_sponsor_ticket_link(sponsor, tickets).deliver_now
    end
    true
  end

end
