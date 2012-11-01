class UsersController < ApplicationController
  before_filter :require_user, :except => [:new, :create]
  before_filter :require_admin, :only => [:index, :delete_bio, :speaker, :create_speaker, :phone_list, :dietary_requirements]
  before_filter :require_admin_or_self, :only => [:show, :edit, :update]
  
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
    logger.debug("Looking for " + params[:id])
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
    #Default to manual payement. Paypal is expensive, and senderegning.no works fine.
    @user.registration.manual_payment = true
    @user.registration.ticket_type_old = params[:free_ticket] || params[:ticket_type_old] || params[:ticket_type] || 'full_price'
    if @user.registration.ticket_type_old == 'full_price' && Time.now < AppConfig.early_bird_ends
      @user.registration.ticket_type_old = 'early_bird'
    end
    @user.registration.includes_dinner = @user.registration.discounted_ticket?
  end

  def edit
    @user = User.find(params[:id])
    puts @user.inspect
    puts @user.bio.inspect
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
          Time.now < AppConfig.early_bird_ends ? @user.registration.ticket_type_old = 'early_bird' : @user.registration.ticket_type_old = 'full_price'
        end
        @user.save
        if !@user.registration.save
          raise @user.registration.errors.inspect
        end

        UserSession.create(:login => @user.email, :password => @user.password)

        if @user.registration.manual_payment
          flash[:notice] = "We will contact you to confirm the details."
          BoosterMailer.manual_registration_confirmation(@user).deliver
          BoosterMailer.manual_registration_notification(@user, user_url(@user)).deliver
          redirect_to @user
        elsif @user.registration.free_ticket
          flash[:notice] = "We will contact you to confirm the details."
          BoosterMailer.free_registration_confirmation(@user).deliver
          BoosterMailer.free_registration_notification(@user, user_url(@user)).deliver
          redirect_to @user
        else
          BoosterMailer.registration_confirmation(@user).deliver
          p "payment url: #{payment_notifications_url}"
          redirect_to @user.registration.payment_url(payment_notifications_url, user_url(@user))
        end
      else
        flash[:error] = "An error occured. Please follow the instructions below."
        render :action => 'new'
      end
    end
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
    @user = User.find(params[:id])
    @user.roles_will_change!
    @user.roles = params[:roles].join(",") unless params[:roles] == nil
    if @user.update_attributes(params[:user])
      flash[:notice] = "Updated profile."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def updated_dinner_attendance(dinner_status)
    flash[:notice] = "Thank you for updating your dinner attendance. #{dinner_status}"
    redirect_to current_users_path
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
