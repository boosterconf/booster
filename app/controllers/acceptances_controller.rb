class AcceptancesController < ApplicationController

  before_filter :require_admin

  def index
    @talks = Talk.all_with_speakers

    @types = {
        accepted: Talk.count_accepted,
        accepted_and_confirmed: Talk.count_accepted_and_confirmed,
        refused: Talk.count_refused,
        pending: Talk.count_pending,
        could_not_attend: Talk.could_not_attend
    }
  end

  def accept
    @talk = Talk.find(params[:id], include: [{ users: :registration }])

    return redirect_on_email_sent if @talk.email_sent

    @talk.accept!
    @talk.save
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' accepted."
  end

  def refuse
    @talk = Talk.find(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    @talk.refuse!
    @talk.save!
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' refused."
  end

  def could_not_attend
    @talk = Talk.find(params[:id])

    @talk.could_not_attend!
    @talk.speakers_confirmed = false
    @talk.save!
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' set to status 'could not attend'"
  end

  def await
    @talk = Talk.find(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    @talk.regret! #Set to pending :)
    @talk.save
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' put on hold."
  end

  def confirm
    @talk = Talk.find(params[:id])

    unless @talk.accepted?
      return redirect_to acceptances_path, error: "Cannot confirm speaker on talk that is not accepted"
    end

    @talk.speakers_confirmed = true
    @talk.save
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name} confirmed for talk '#{@talk.title}'"
  end

  def unconfirm
    @talk = Talk.find(params[:id])

    unless @talk.speakers_confirmed?
      redirect_to acceptances_path, error: "Cannot cancel speaker that is not confirmed"
    end

    @talk.speakers_confirmed = false
    @talk.save
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name} cancelled for talk '#{@talk.title}'"
  end

  def send_mail
    @talk = Talk.find(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    if @talk.refused?
      @talk.speakers.each { |speaker| BoosterMailer.talk_refusation_confirmation(@talk, speaker.user, current_user_url).deliver }
    elsif @talk.accepted?
      @talk.speakers.each { |speaker| BoosterMailer.talk_acceptance_confirmation(@talk, speaker.user, current_user_url).deliver }
    else
      return redirect_to acceptances_path, error: "Cannot send email for talk '#{@talk.title}': Talk not accepted/refused yet!"
    end

    @talk.email_sent = true
    @talk.save

    redirect_to acceptances_path, notice: "Sent mail about '#{@talk.title}'"
  end

  private
  def redirect_on_email_sent
    redirect_to acceptances_path, error: "Cannot send email for talk '#{@talk.title}': Email already sent!"
  end
end