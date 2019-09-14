class RegisterShortTalkController < ApplicationController
  include CfpClosedRedirect

  before_action :require_admin, :only => [:invited_talk, :create_invited_talk]
  before_action :redirect_when_cfp_closed_for_lightning_talks, only: [:start, :create_user, :create_talk]

  def start
    if current_user
      redirect_to '/register_short_talk/talk'
    end
    @user = User.new
  end

  def create_user
    @user = User.new(create_user_params)
    @user.accepted_privacy_guidelines = true
    @user.email.strip! if @user.email.present?
    @user.registration_ip = request.remote_ip
    @user.roles = params[:roles].join(',') if params[:roles]

    if @user.save
      sign_in @user
      redirect_to '/register_short_talk/talk'
    else
      render action: :start
    end
  end

  def talk
    @talk = ShortTalk.new
  end

  def create_talk
    @talk = ShortTalk.new(talk_params)
    @talk.talk_type = TalkType.find_by_name("Short talk")
    @talk.year = AppConfig.year
    @talk.users << current_user
    if @talk.save
      BoosterMailer.talk_confirmation(current_user, @talk, talk_url(@talk)).deliver_now
      SlackNotifier.notify_talk(@talk)
      if current_user.has_all_statistics? && current_user.bio && current_user.bio.good_enough?
        redirect_to '/register_short_talk/finish'
      else
        redirect_to '/register_short_talk/details'
      end
    else
      render action: :talk
    end
  end

  def invited_talk
    @talk = ShortTalk.new
  end

  def create_invited_talk
    @talk = ShortTalk.new(talk_params)
    @talk.talk_type = TalkType.find_by_name("Short talk")
    @talk.year = AppConfig.year
    @keynote.accept!
    if @talk.save
      if(params[:notify_speaker] == "1")
        BoosterMailer.talk_confirmation(current_user, @talk, talk_url(@talk)).deliver_now
      end
      SlackNotifier.notify_talk(@talk)

      redirect_to talk_path(@talk)
    else
      render action: :invited_talk
    end
  end

  def details
    @user = current_user
    @user.create_bio
  end

  def create_details
    @user = current_user
    @user.update_attributes(create_details_params)

    if @user.save
      redirect_to '/register_short_talk/finish'
    else
      render action: :details
    end
  end

  private
  def talk_params
    (current_user&.is_admin?) ?
        params.require(:talk).permit! :
        params.require(:talk).permit(:language, :title, :description, :equipment, :has_slides)
  end

  def create_user_params
    (current_user&.is_admin?) ?
        params.require(:user).permit! :
        params.require(:user).permit(:opt_in_to_email_list, :first_name, :last_name, :company, :email, :phone_number, :password, :password_confirmation, :roles)
  end

  def create_details_params
    (current_user&.is_admin?) ?
        params.require(:user).permit! :
        params.require(:user).permit(:gender,:birthyear,:hear_about,bio_attributes: [:title,:twitter_handle,:blog,:bio,:id])
  end

end
