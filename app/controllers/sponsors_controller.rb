class SponsorsController < ApplicationController

  before_filter :require_admin

  respond_to :html, :js

  def index
    @sponsors = Sponsor.all(:include => :user).sort

    @number_of_sponsors_per_user = @sponsors.group_by(&:user).map {|user, sponsors| [user != nil ? user.name : "(none)", sponsors.length]}.sort { |a, b| a[1] <=> b[1] }.reverse!

  end

  def show
    @sponsor = Sponsor.find(params[:id])

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
      redirect_to @sponsor, notice: 'Sponsor was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @sponsor = Sponsor.find(params[:id])

    @sponsor.assign_attributes(params[:sponsor])

    if @sponsor.status_changed?
      event = Event.new(:user => current_user, :sponsor => @sponsor, :comment => "Sponsor status changed to #{@sponsor.status_text}")
      event.save
    end

    if @sponsor.save
      redirect_to @sponsor, notice: 'Sponsor was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @sponsor = Sponsor.find(params[:id])
    @sponsor.destroy

    redirect_to sponsors_url
  end

  def email
    @sponsor = Sponsor.find(params[:id])

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
end