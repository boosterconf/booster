class RegisterLightningTalkController < ApplicationController

  def start
	  @user = User.new
  end

  def create_user
    @user = User.new(params[:user])

    @user.roles = params[:roles].join(",") unless params[:roles] == nil
    p params.inspect

    if @user.save
      UserSession.create(:login => @user.email, :password => @user.password)
      redirect_to "/register_lightning_talk/talk"
    else
      render :action => "start"
    end
  end

  def talk
    @talk = Talk.new
  end

  def create_talk
    @talk = Talk.new(params[:talk])
    @talk.talk_type = TalkType.find_by_name("Lightning talk")

    if @talk.save
      redirect_to "/register_lightning_talk/details"
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
      redirect_to "/register_lightning_talk/finish"
    else
      render :action => "details"
    end
  end

end