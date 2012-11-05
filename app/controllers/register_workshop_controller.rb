class RegisterWorkshopController < ApplicationController

  def start
    if current_user
      redirect_to register_workshop_talk_url
    end
    @user = User.new
    @user.registration = Registration.new
  end

  def create_user
    @user = User.new(params[:user])
    @user.registration = Registration.new
    @user.registration.ticket_type_old = "speaker"
    @user.accepted_privacy_guidelines = true
    @user.email.strip! if @user.email.present?
    @user.registration_ip = request.remote_ip
    @user.roles = params[:roles].join(",") unless params[:roles] == nil
    p params.inspect

    if @user.save
      UserSession.create(:login => @user.email, :password => @user.password)
      @user.registration.save!
      redirect_to register_workshop_talk_url
    else
      render :action => "start"
    end
  end

  def talk
    @talk = Talk.new
  end

  def create_talk
    @talk = Talk.new(params[:talk])
    @talk.language = "english"
    @talk.users << current_user
    if @talk.save
      redirect_to register_workshop_details_url
    else
      render :action => "talk"
    end
  end

  def details
    @user = current_user
  end

  def create_details
    @user = current_user
    @user.update_attributes(params[:user])

    if @user.save
      redirect_to register_workshop_finish_url
    else
      render :action => "details"
    end
  end

end