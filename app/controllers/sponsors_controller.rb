class SponsorsController < ApplicationController

  before_filter :require_admin
  before_filter :find_sponsor, only: [:show, :update, :destroy, :email]

  respond_to :html, :js

  def index
    @sponsors = Sponsor.all(:include => :user).sort

    @number_of_sponsors_per_user = @sponsors.group_by(&:user).map { |user, sponsors| [user != nil ? user.full_name : "(none)", sponsors.length] }.sort { |a, b| a[1] <=> b[1] }.reverse!

    @events = Event.last(15).reverse

  end

  def show
  end

  def new
    @users = User.all_organizers
    @sponsor = Sponsor.new
  end

  def edit
    @users = User.all_organizers
    @sponsor = Sponsor.find(params[:id], :include => :events)

    @event = Event.new(:sponsor => @sponsor)
  end

  def create
    @sponsor = Sponsor.new(params[:sponsor])

    if @sponsor.save
      redirect_to sponsors_path, notice: 'Sponsor was successfully created.'
    else
      render action: :new
    end
  end

  def update
    @sponsor.assign_attributes(params[:sponsor])

    User.transaction do
      Sponsor.transaction do

        Rails.cache.delete('all_accepted_sponsors')

        if @sponsor.status_changed?
          event = Event.new(:user => current_user, :sponsor => @sponsor, :comment => "Sponsor status changed to #{@sponsor.status_text}")
          event.save

          if @sponsor.status == 'accepted'
            create_sponsor_tickets
            SlackNotifier.notifySponsor(@sponsor)
          end
        end

        respond_to do |format|
          format.html {
            if @sponsor.save
              redirect_to sponsors_path, notice: "Sponsor #{@sponsor.name} was successfully updated."
            else
              render action: :edit
            end
          }
          format.js {
            @sponsors = Sponsor.all(:include => :user).sort
            @number_of_sponsors_per_user = @sponsors.group_by(&:user).map { |user, sponsors| [user != nil ? user.full_name : "(none)", sponsors.length] }.sort { |a, b| a[1] <=> b[1] }.reverse!
            @events = Event.last(15).reverse
            flash[:notice] = "Status for #{@sponsor.name} changed to #{Sponsor::STATES[@sponsor.status]} "
            render
          }
        end
      end
    end
  end

  def create_sponsor_tickets
    first_sponsor_ticket = User.create_unfinished(nil, 'sponsor')
    second_sponsor_ticket = User.create_unfinished(nil, 'sponsor')

    first_sponsor_ticket.company = @sponsor.name
    second_sponsor_ticket.company = @sponsor.name

    first_sponsor_ticket.save!(:validate => false)
    second_sponsor_ticket.save!(:validate => false)
  end

  def destroy
    @sponsor.destroy

    redirect_to sponsors_url, notice: "Sponsor #{@sponsor.name} was successfully updated."
  end

  def email
    if @sponsor.is_ready_for_email?
      BoosterMailer.initial_sponsor_mail(@sponsor).deliver
      @sponsor.status = 'contacted'
      @sponsor.last_contacted_at = Time.now.to_datetime
      @sponsor.save

      event = Event.new(:user => current_user, :sponsor => @sponsor, :comment => "Email sent")
      event.save

      redirect_to(sponsors_path, :notice => 'Email was sent and sponsor status set to \'Contacted\'.')
    else
      flash[:error] = 'No email sent: must have status suggested and responsible set'
      redirect_to sponsors_path
    end
  end

  def ajax_email
    if @sponsor.is_ready_for_email?
      BoosterMailer.initial_sponsor_mail(@sponsor).deliver
      @sponsor.status = 'contacted'
      @sponsor.last_contacted_at = Time.now.to_datetime
      if @sponsor.save
        event = Event.new(:user => current_user, :sponsor => @sponsor, :comment => "Email sent")
        event.save

        redirect_to(sponsors_path, :notice => "Email was sent to #{@sponsor.name} and sponsor status set to \'Contacted\'.")
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

end