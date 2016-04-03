class SponsorsController < ApplicationController

  before_filter :require_admin
  before_filter :find_sponsor, only: [:update, :destroy, :email]
  before_filter :find_sponsors, only: [:index, :update]
  before_filter :find_events_and_stats, only: [:index, :update]

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
    @sponsor = Sponsor.find(params[:id], include: :events)

    @event = Event.new(sponsor: @sponsor)
  end

  def create
    @sponsor = Sponsor.new(params[:sponsor])

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
    @sponsor.assign_attributes(params[:sponsor])

    User.transaction do
      Sponsor.transaction do

        Rails.cache.delete('all_accepted_sponsors')

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
        BoosterMailer.initial_sponsor_mail(@sponsor).deliver
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

  def ajax_email
    @users = User.all_organizers
    if @sponsor.is_ready_for_email?
      BoosterMailer.initial_sponsor_mail(@sponsor).deliver
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
  def find_sponsor
    @sponsor = Sponsor.find(params[:id])
  end

  def find_sponsors
    @sponsors = Sponsor.all(:include => :user).sort
  end

  def find_events_and_stats
    @number_of_sponsors_per_user = @sponsors.group_by(&:user).map { |user, sponsors| [user != nil ? user.full_name : "(none)", sponsors.length] }.sort { |a, b| a[1] <=> b[1] }.reverse!
    @stats = {
        'Accepted' => Sponsor.count(:conditions => "status = 'accepted'"),
        'Declined' => Sponsor.count(:conditions => "status = 'declined'"),
        'In dialogue' => Sponsor.count(:conditions => "status = 'dialogue'"),
        'Suggested (with email)' => Sponsor.count(:conditions => "status = 'suggested' AND email != ''"),
        'Suggested (missing email)' => Sponsor.count(:conditions => "status = 'suggested' AND email = ''"),
        'Contacted' => Sponsor.count(:conditions => "status = 'contacted'"),
        'Reminded' => Sponsor.count(:conditions => "status = 'reminded'"),
        'Don\'t ask' => Sponsor.count(:conditions => "status = 'never'"),
        'Both years' => Sponsor.count(:conditions => "status = 'accepted' AND was_sponsor_last_year = 't'"),
        'New this year' => Sponsor.count(:conditions => "status = 'accepted' AND was_sponsor_last_year = 'f'")
    }

    @events = Event.last(15).reverse
  end

end
