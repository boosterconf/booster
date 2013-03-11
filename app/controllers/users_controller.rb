class UsersController < ApplicationController
  before_filter :require_user, :except => [:new, :create, :from_reference, :group_registration, :create_group_registration]
  before_filter :require_admin, :only => [:index, :delete_bio, :phone_list, :dietary_requirements]
  before_filter :require_admin_or_self, :only => [:show, :edit, :update]
  before_filter :require_admin_or_speaker, :only => [:create_bio]

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

    init_registration

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def new
    if current_user && !current_user.is_admin
      redirect_to current_user_url
      return
    end

    if no_more_registrations_allowed
      redirect_to_front_page
      return
    end

    @user = User.new
    @user.registration = Registration.new
    if params[:invited]
      @user.registration.ticket_type_old = "speaker"
      @user.invited = true
      @user.registration.manual_payment = false
    else
      # Default to manual payment. Paypal is expensive, and sendregning.no works fine.
      @user.registration.manual_payment = true
      @user.registration.ticket_type_old = params[:ticket_type_old] || current_normal_ticket_type
    end

    @user.registration.includes_dinner = !@user.registration.discounted_ticket?
  end

  def current_normal_ticket_type
    early_bird_is_active? ? "early_bird" : "full_price"
  end

  def edit
    @user = User.find(params[:id])
    init_registration
  end

  def init_registration
    unless @user.registration
      @user.registration = Registration.new
      # Default to manual payment. Paypal is expensive, and sendregning.no works fine.
      @user.registration.manual_payment = true
      @user.registration.ticket_type_old = current_normal_ticket_type
      @user.registration.save!
    end
  end

  def create
    if current_user && !current_user.is_admin
      redirect_to current_user_url
      return
    end

    if no_more_registrations_allowed
      redirect_to_front_page
      return
    end

    User.transaction do
      @user = User.new(params[:user])
      @user.email.strip! if @user.email.present?
      @user.registration_ip = request.remote_ip
      @user.roles = params[:roles].join(",") unless params[:roles] == nil

      if @user.valid?
        unless @user.registration.free_ticket || @user.registration.discounted_ticket?
          @user.registration.ticket_type_old = current_normal_ticket_type
        end

        @user.save

        unless @user.registration.save
          raise @user.registration.errors.inspect
        end

        unless current_user
          login @user
        end

        if @user.registration.manual_payment
          flash[:notice] = "We will contact you to confirm the details."
          BoosterMailer.manual_registration_confirmation(@user).deliver
          BoosterMailer.manual_registration_notification(@user, user_url(@user)).deliver
          #@user.registration.invoiced = SendRegning.new.send_invoice(
          #    PAYMENT_CONFIG['send_regning_url'], @user.id, @user.name, @user.email, @user.zip, @user.city,
          #    @user.registration.ticket_type_old, @user.registration.ticket_price)

          redirect_to @user
        elsif @user.registration.free_ticket
          flash[:notice] = "We will contact you to confirm the details."
          #BoosterMailer.free_registration_confirmation(@user).deliver
          BoosterMailer.free_registration_notification(current_user, @user, user_url(@user)).deliver
          redirect_to @user
        else
          BoosterMailer.registration_confirmation(@user).deliver
          redirect_to @user.registration.payment_url(payment_notifications_url, user_url(@user))
        end
      else
        flash[:error] = "An error occured. Please follow the instructions below."
        render :action => 'new'
      end
    end
  end

  def login(user)
    UserSession.create(user)
  end

  def early_bird_is_active?
    Time.now < AppConfig.early_bird_ends
  end

  def no_more_registrations_allowed
    User.count >= AppConfig.max_users_limit
  end

  def redirect_to_front_page
    flash[:error] = "We have reached the limit on the number of participants for this conference. Please contact us at kontakt@boosterconf.no and we will see what we can do."
    logger.error("Hard limit for number of users (#{AppConfig.max_users_limit}) has been reached. Please take action.")
    BoosterMailer.error_mail("Error on boosterconf.no", "Hard limit for number of users (#{AppConfig.max_users_limit}) has been reached. Please take action.").deliver
    redirect_to root_path
  end

  def create_bio
    @user = User.find(params[:id])
    if @user.bio == nil
      @user.bio = Bio.new
    end
    render :action => 'edit'
  end

  def update
    @user = User.find(params[:id], :include => :registration)
    @user.roles_will_change!
    @user.roles = params[:roles].join(",") unless params[:roles] == nil
    @user.assign_attributes(params[:user])
    if @user.valid?
      @user.registration.unfinished = false
      @user.save
      flash[:notice] = "Updated profile."
      redirect_to @user
    else
      render :action => 'edit'
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

  def delete_bio
    @user = User.find(params[:id])
    if @user.bio.delete
      flash[:notice] = "Removed bio"
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
    @user.registration = Registration.new
  end

  # TODO: Lag egen type for skeleton users
  def create_skeleton
    email = params[:user][:email]

    if !email.empty? && user_already_exists(email)
      flash[:error] = "This email already has a user"
      render :action => 'new_skeleton'
    else
      @user = User.create_unfinished(email, params[:user][:registration_attributes][:ticket_type_old], params[:user][:name])
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

    users = emails.gsub(/[,;:\n]/, " ").split.map do |email|
      user = User.create_unfinished(email, current_normal_ticket_type)
      user.company = params[:company]
      user.registration.invoice = @invoice
      user
    end

    existing_users = users.select {|u| user_already_exists(u.email)}
    new_users = users.select {|u| !user_already_exists(u.email)}

    if all_emails_are_valid(new_users) && @invoice.valid?
      @invoice.save!

      new_users.each do |user|
        user.save!(:validate => false)
        BoosterMailer.ticket_assignment(user).deliver
      end

      existing_users.each do |u|
        user = User.find_by_email(u.email)
        user.company = params[:company]
        user.registration.invoice = @invoice
        user.save!(:validate => false)
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
        total += user.registration.price || 0 if user.registration && user.registration.paid?
      end
      per_date << total
    end
    per_date
  end

end
