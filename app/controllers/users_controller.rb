class UsersController < ApplicationController
  before_filter :require_user, except: [:new, :create, :from_reference, :group_registration, :create_group_registration]
  before_filter :require_admin, only: [:index, :delete_bio, :phone_list, :dietary_requirements]
  before_filter :require_admin_or_self, only: [:show, :edit, :update]
  before_filter :require_admin_or_speaker, only: [:create_bio]
  before_filter :require_unauthenticated_or_admin, only: [:new, :create]
  before_filter :registration_is_open, only: [:new, :create]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    if params[:id] == 'current'
      @user = current_user
    else
      @user = User.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def new
    @user = User.new
    if params[:invited] && current_user.is_admin?
      @user.invited = true
      @user.build_bio
    else
      # Default to manual payment. Paypal is expensive, and sendregning.no works fine.
      @user.registration.manual_payment = true
      @user.registration.ticket_type_old = params[:ticket_type_old] || Registration.current_normal_ticket_type
    end

    @user.registration.includes_dinner = !@user.registration.discounted_ticket?
  end

  def edit
    @user = User.find(params[:id])
    init_registration
  end

  def create
    puts params[:user]

    User.transaction do
      @user = User.new(params[:user])
      @user.email.strip! if @user.email.present?
      @user.registration_ip = request.remote_ip
      @user.roles = params[:roles].join(",") if params[:roles]

      unless @user.registration.free_ticket || @user.registration.discounted_ticket?
        @user.registration.ticket_type_old = Registration.current_normal_ticket_type
      end

      if @user.invited && current_user.is_admin?
        @user.registration.registration_complete = true
        @user.registration.ticket_type_old = 'speaker'
        @user.registration.manual_payment = false
      end

      if @user.save

        if @user.invited
          flash[:notice] = "You have registered #{@user.email}"
          redirect_to @user
        elsif @user.registration.manual_payment
          flash[:notice] = "We will contact you to confirm the details."
          BoosterMailer.manual_registration_confirmation(@user).deliver
          BoosterMailer.manual_registration_notification(@user, user_url(@user)).deliver
          redirect_to @user
        elsif @user.registration.free_ticket
          flash[:notice] = "We will contact you to confirm the details."
          BoosterMailer.free_registration_notification(current_user, @user, user_url(@user)).deliver
          redirect_to @user
        else
          BoosterMailer.registration_confirmation(@user).deliver
          redirect_to @user.registration.payment_url(payment_notifications_url, user_url(@user))
        end
      else
        flash[:error] = "An error occured. Please follow the instructions below."
        render action: :new
      end
    end
  end

  def login(user)
    UserSession.create(user)
  end

  def redirect_to_front_page
    flash[:error] = "We have reached the limit on the number of participants for this conference. Please contact us at kontakt@boosterconf.no and we will see what we can do."
    logger.error("Hard limit for number of users (#{AppConfig.max_users_limit}) has been reached. Please take action.")
    BoosterMailer.error_mail("Error on boosterconf.no", "Hard limit for number of users (#{AppConfig.max_users_limit}) has been reached. Please take action.").deliver
    redirect_to root_path
  end

  def create_bio
    @user = User.find(params[:id])

    unless @user.bio
      @user.build_bio.save
    end

    render action: :edit
  end

  def update
    @user = User.find(params[:id], include: :registration)
    @user.roles_will_change!
    @user.roles = params[:roles].join(",") if params[:roles]
    @user.assign_attributes(params[:user])
    @user.registration.unfinished = false
    if @user.save
      flash[:notice] = 'Updated profile.'
      redirect_to @user
    else
      render action: :edit
    end
  end

  def updated_dinner_attendance(dinner_status)
    flash[:notice] = "Thank you for updating your dinner attendance. #{dinner_status}"
    redirect_to current_user_path
  end

  def attending_dinner
    current_user.attending_dinner!
    updated_dinner_attendance("You are registered as attending the dinner.")
  end

  def not_attending_dinner
    current_user.not_attending_dinner!
    updated_dinner_attendance("You are registered as not attending the dinner")
  end

  def attending_speakers_dinner
    current_user.attending_speakers_dinner(true)
    updated_dinner_attendance("You are registered as attending the dinner.")
  end

  def not_attending_speakers_dinner
    current_user.attending_speakers_dinner(false)
    updated_dinner_attendance("You are registered as not attending the dinner")
  end

  def delete_bio
    @user = User.find(params[:id])
    if @user.bio.delete
      flash[:notice] = 'Removed bio'
    else
      flash[:notice] = "Couldn't remove bio"
    end
    redirect_to @user
  end

  def phone_list
    @users = User.all(:order => "registrations.ticket_type_old, name", :include => :registration, :conditions => "registrations.ticket_type_old = 'volunteer' OR registrations.ticket_type_old = 'organizer'")
  end

  def dietary_requirements
    @users = User.all(:order => "registrations.ticket_type_old, name", :include => :registration, :conditions => "dietary_requirements IS NOT NULL AND dietary_requirements != ''")
  end

  def new_skeleton
    @user = User.new
  end

  # TODO: Lag egen type for skeleton users
  def create_skeleton
    email = params[:user][:email]

    if email.present? && user_already_exists(email)
      flash[:error] = "This email already has a user"
      render action: 'new_skeleton'
    else
      @user = User.create_unfinished(email, params[:user][:registration_attributes][:ticket_type_old], params[:user][:first_name], params[:user][:last_name])
      @user.company = params[:user][:company]
      @user.save!(:validate => false)

      flash[:notice] = "Skeleton user created - creation link is #{user_from_reference_url(@user.registration.unique_reference)}"
      redirect_to new_skeleton_user_path

    end
  end

  def group_registration
    @invoice = Invoice.new
  end

  def create_group_registration
    @invoice = Invoice.new(params[:invoice])

    emails = params[:emails]

    users = tokenize(emails).map do |email|
      user = User.create_unfinished(email, Registration.current_normal_ticket_type)
      user.company = params[:company]
      user.registration.invoice = @invoice
      user
    end


    existing_users, new_users = users.partition { |u| user_already_exists(u.email) }

    if all_emails_are_valid(new_users) && @invoice.valid?
      @invoice.save!

      User.transaction do
        new_users.each do |user|
          user.save!(validate: false)
          BoosterMailer.ticket_assignment(user).deliver
        end

        existing_users.each do |u|
          user = User.find_by_email(u.email)
          user.company = params[:company]
          user.registration.invoice = @invoice
          user.save!(:validate => false)
        end
      end
      render :action => 'group_registration_confirmation'
    else
      flash[:error] = "Contains one or more invalid email address: #{emails}"
      render :action => 'group_registration'
    end
  end

  def all_emails_are_valid(users)
    users.each do |user|
      return false unless user.has_valid_email? && !user_already_exists(user.email)
    end
    true
  end

  def user_already_exists(email)
    User.find_by_email(email)
  end

  def from_reference

    if current_user
      redirect_to current_user_url
      return
    end

    registration = Registration.find_by_unique_reference(params[:reference], :include => [:user])

    unless registration.present?
      flash[:error] = "This link does no longer work"
      return
    end

    login registration.user

    redirect_to edit_user_path registration.user
  end

  protected
  def total_by_date(users, date_range)
    users_by_date = users.group_by { |u| u.created_at.to_date }
    per_date = []
    total = 0
    for day in date_range do
      total += users_by_date[day].size if users_by_date[day]
      per_date << total
    end
    per_date
  end

  def total_price_per_date(users, date_range)
    users_by_date = users.group_by { |u| u.created_at.to_date }
    per_date = []
    total = 0
    for day in date_range do
      for user in users_by_date[day] || []
        total += user.registration.price || 0 if user.registration.paid?
      end
      per_date << total
    end
    per_date
  end

  def tokenize(string)
    string.gsub(/[,;:\n]/, " ").split
  end

  def registration_is_open
    if no_more_registrations_allowed
      return redirect_to_front_page
    end
  end

  def no_more_registrations_allowed
    User.count >= AppConfig.max_users_limit
  end
end
