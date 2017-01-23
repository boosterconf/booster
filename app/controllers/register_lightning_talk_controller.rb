class RegisterLightningTalkController < ApplicationController

  def start
    if DateTime.now > Dates::CFP_LIGHTNING_ENDS
      redirect_to '/'
      return
    end

    if current_user
      redirect_to '/register_lightning_talk/talk'
    end
    @user = User.new
    @user.registration = Registration.new
  end

  def create_user
    if DateTime.now > Dates::CFP_LIGHTNING_ENDS
      redirect_to '/'
      return
    end

    @user = User.new(params[:user])
    @user.registration = Registration.new
    @user.registration.ticket_type = TicketType.lightning
    @user.registration.manual_payment = true
    @user.accepted_privacy_guidelines = true
    @user.email.strip! if @user.email.present?
    @user.registration_ip = request.remote_ip
    @user.roles = params[:roles].join(',') unless params[:roles] == nil

    if @user.save
      UserSession.create(:login => @user.email, :password => @user.password)
      @user.registration.save!
      redirect_to '/register_lightning_talk/talk'
    else
      render action: :start
    end
  end

  def talk
    @talk = LightningTalk.new
    @talk.talk_type = TalkType.find_by_name("Lightning talk")
  end

  def create_talk
    if DateTime.now > Dates::CFP_LIGHTNING_ENDS
      redirect_to '/'
      return
    end

    @talk = LightningTalk.new(params[:talk])
    @talk.talk_type = TalkType.find_by_name("Lightning talk")
    @talk.year = AppConfig.year
    @talk.users << current_user
    if @talk.save
      current_user.update_ticket_type!

      BoosterMailer.talk_confirmation(current_user, @talk, talk_url(@talk)).deliver_now
      SlackNotifier.notify_talk(@talk)

      if current_user.has_all_statistics? && current_user.bio && current_user.bio.good_enough?
        redirect_to '/register_lightning_talk/finish'
      else
        redirect_to '/register_lightning_talk/details'
      end
    else
      render action: :talk
    end
  end

  def details
    @user = current_user
    @user.create_bio
  end

  def create_details
    @user = current_user
    @user.update_attributes(params[:user])

    if @user.save
      redirect_to '/register_lightning_talk/finish'
    else
      render action: :details
    end
  end

end