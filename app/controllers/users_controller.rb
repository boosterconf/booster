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
    @user = User.new
    @user.registration = Registration.new
    @user.registration.manual_payment = params[:manual_payment]
    @user.registration.ticket_type_old = params[:free_ticket] || params[:ticket_type_old] || params[:ticket_type] || 'full_price'
    if @user.registration.ticket_type_old == 'full_price' && Time.now < App.early_bird_end_date
      @user.registration.ticket_type_old = 'early_bird'
    end
    @user.registration.includes_dinner = @user.registration.discounted_ticket?
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    User.transaction do
      @user = User.new(params[:user])
      #@user.registration = @user.build_registration
      @user.email.strip! if @user.email.present?
      @user.registration_ip = request.remote_ip

      if @user.valid?
        unless @user.registration.free_ticket || @user.registration.discounted_ticket?
          Time.now < App.early_bird_end_date ? @user.registration.ticket_type_old = 'early_bird' : @user.registration.ticket_type_old = 'full_price'
        end
        @user.save
        if !@user.registration.save
          raise @user.registration.errors.inspect
        end

        UserSession.create(:login => @user.email, :password => @user.password)

        if @user.registration.manual_payment
          flash[:notice] = "We will contact you to confirm the details"
          RootsMailer.manual_registration_confirmation(@user).deliver
          RootsMailer.manual_registration_notification(@user, user_url(@user)).deliver
          redirect_to @user
        elsif @user.registration.free_ticket
          flash[:notice] = "We will contact you to confirm the details"
          RootsMailer.free_registration_confirmation(@user).deliver
          RootsMailer.free_registration_notification(@user, user_url(@user)).deliver
          redirect_to @user
        else
          RootsMailer.registration_confirmation(@user).deliver
          redirect_to @user.registration.payment_url(payment_notifications_url, user_url(@user))
        end
      else
        flash[:error] = "An error occured. Please follow the instructions below."
        render :action => 'new'
      end
    end
  end
end
