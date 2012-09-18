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
    @user.registration.free_ticket = !params[:free_ticket].blank?
    @user.registration.ticket_type_old = params[:free_ticket] || params[:ticket_type_old] || params[:ticket_type] || 'full_price'
    if @user.registration.ticket_type_old == 'full_price' && Time.now < App.early_bird_end_date
      @user.registration.ticket_type_old = 'early_bird'
    end
    @user.registration.includes_dinner = @user.registration.discounted_ticket?
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  def create
    User.transaction do
      @user = User.new(params[:user])
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

        UserSession.login(@user.email, @user.password)

        if @user.registration.manual_payment
          flash[:notice] = "We will contact you to confirm the details"
          #RootsMailer.deliver_manual_registration_confirmation(@user)
          #RootsMailer.deliver_manual_registration_notification(@user, user_url(@user))
          redirect_to @user
        elsif params[:speaker]
          @user.registration.ticket_type_old = 'new_speaker'
          @user.save
          flash[:notice] = "Register details for your talk/tutorial"
          #RootsMailer.deliver_speaker_registration_confirmation(@user)
          #RootsMailer.deliver_speaker_registration_notification(@user, user_url(@user))
          redirect_to new_talk_url
        elsif @user.registration.free_ticket
          flash[:notice] = "We will contact you to confirm the details"
          #RootsMailer.deliver_free_registration_confirmation(@user)
          #RootsMailer.deliver_free_registration_notification(@user, user_url(@user))
          redirect_to @user
        else
          #RootsMailer.deliver_registration_confirmation(@user)
          redirect_to @user.registration.payment_url(payment_notifications_url, user_url(@user))
        end
      else
        flash[:error] = "An error occured. Please follow the instructions below."
        render :action => 'new'
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
