require "securerandom"

class RegisterWorkshopController < ApplicationController
  include CfpClosedRedirect

  before_action :setup_talk_types, only: [:talk, :create_talk]
  before_action :redirect_when_cfp_closed_for_workshops, only: [:start, :create_user, :create_talk, :talk]

  def start
    if current_user
      redirect_to register_workshop_talk_url
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
      UserSession.create(login: @user.email, password: @user.password)
      redirect_to register_workshop_talk_url
    else
      render action: :start
    end
  end

  def talk
    @workshop = Workshop.new
  end

  def create_talk

    @workshop = Workshop.new(talk_params)
    @workshop.appropriate_for_roles = params[:appropriate_for_roles].join(',') if params[:appropriate_for_roles]
    @workshop.users << current_user
    if @workshop.save

      if has_entered_additional_speaker_email(@workshop)
        additional_speaker = find_additional_speaker(@workshop)
        @workshop.users << additional_speaker
        @workshop.save!
      end

      BoosterMailer.talk_confirmation(current_user, @workshop, talk_url(@workshop)).deliver_now
      SlackNotifier.notify_talk(@workshop)

      if current_user.has_all_statistics?
        redirect_to register_workshop_finish_url
      else
        redirect_to register_workshop_details_url
      end
    else
      render action: :talk
    end
  end

  def find_additional_speaker(workshop)
    additional_speaker_email = workshop.additional_speaker_email

    unless additional_speaker_already_has_registered_user(additional_speaker_email)
      additional_speaker = User.create_unfinished(additional_speaker_email, TicketType.speaker)
      additional_speaker.save(:validate => false)
      BoosterMailer.additional_speaker(current_user, additional_speaker, @workshop).deliver_now
    end

    User.where(email: additional_speaker_email).first
  end

  def additional_speaker_already_has_registered_user(additional_speaker_email)
    User.find_by_email(additional_speaker_email)
  end

  def has_entered_additional_speaker_email(workshop)
    workshop.additional_speaker_email.present?
  end

  def details
    @user = current_user
    @user.create_bio
  end

  def create_details

    @user = current_user
    @user.update_attributes(params[:user])

    if @user.save
      redirect_to register_workshop_finish_url
    else
      render :action => :details
    end
  end

  private

  def setup_talk_types
    @talk_types = TalkType.workshops
  end

  def talk_params
    (current_user&.is_admin?) ?
        params.require(:talk).permit! :
        params.require(:talk).permit(:talk_type_id, :title, :description, :equipment, :appropriate_for_roles,
                                     :outline, :max_participants, :speaking_history, :participant_requirements, :equipment, :additional_speaker_email)
  end

  def create_user_params
    (current_user&.is_admin?) ?
        params.require(:user).permit! :
        params.require(:user).permit(:first_name, :last_name, :company, :email, :phone_number, :password, :password_confirmation, :roles)
  end

end
