class AcceptancesController < ApplicationController

  before_filter :require_admin

  def index
    @talks       = Talk.all_with_speakers

    num_accepted = Talk.count_accepted
    num_refused  = Talk.count_refused
    num_pending  = Talk.count_pending
    num_could_not_attend  = Talk.could_not_attend
    @types       = {:accepted => num_accepted,
                    :refused  => num_refused,
                    :pending  => num_pending,
                    :could_not_attend  => num_could_not_attend                    
    }
  end

  def accept
    @talk = Talk.find(params[:id], :include => [{:users => :registration}])

    if @talk.email_sent?
      flash[:error] = "Cannot change status on talk '#{@talk.title}': Email already sent!"
      redirect_to :controller => :acceptances
      return
    end

    @talk.accept!
    @talk.save
    @talk.update_speakers(current_user)

    flash[:notice] = "#{@talk.speaker_name}'s talk '#{@talk.title}' accepted."
    redirect_to :controller => :acceptances
  end

  def refuse
    @talk = Talk.find(params[:id])

    if (@talk.email_sent?)
      flash[:error] = "Cannot change status on talk '#{@talk.title}': Email already sent!"
      redirect_to :controller => :acceptances
      return
    end

    @talk.refuse!
    @talk.save!
    @talk.update_speakers(current_user)

    flash[:notice] = "#{@talk.speaker_name}'s talk '#{@talk.title}' refused."
    redirect_to :controller => :acceptances
  end

  def could_not_attend
    @talk = Talk.find(params[:id])

    @talk.could_not_attend!
    @talk.save!
    @talk.update_speakers(current_user)

    flash[:notice] = "#{@talk.speaker_name}'s talk '#{@talk.title}' set to status 'could not attend'"
    redirect_to :controller => :acceptances
  end

  def await
    @talk = Talk.find(params[:id])

    if (@talk.email_sent?)
      flash[:error] = "Cannot change status on talk '#{@talk.title}': Email already sent!"
      redirect_to :controller => :acceptances
      return
    end

    @talk.regret! #Set to pending :)
    @talk.save
    @talk.update_speakers(current_user)

    flash[:notice] = "#{@talk.speaker_name}'s talk '#{@talk.title}' put on hold."
    redirect_to :controller => :acceptances
  end

  def confirm
      @talk = Talk.find(params[:id])

      if not @talk.accepted?
        flash[:error] = "Cannot confirm speaker on talk that is not accepted"
        redirect_to :controller => :acceptances
        return
      end

      @talk.speakers_confirmed = true
      @talk.save
      @talk.update_speakers(current_user)

      flash[:notice] = "#{@talk.speaker_name} confirmed for talk '#{@talk.title}'"
      redirect_to :controller => :acceptances
  end

  def unconfirm
    @talk = Talk.find(params[:id])

    if not @talk.speakers_confirmed?
      flash[:error] = "Cannot cancel speaker that is not confirmed"
      redirect_to :controller => :acceptances
      return
    end

    @talk.speakers_confirmed = false
    @talk.save
    @talk.update_speakers(current_user)

    flash[:notice] = "#{@talk.speaker_name} cancelled for talk '#{@talk.title}'"
    redirect_to :controller => :acceptances
  end

  def send_mail
    @talk = Talk.find(params[:id])

    if @talk.email_sent
      flash[:error] = "Cannot send email for talk '#{@talk.title}': Email already sent!"
      redirect_to :controller => :acceptances
      return
    end

    if @talk.refused?
      @talk.speakers.each { |speaker| BoosterMailer.talk_refusation_confirmation(@talk, speaker.user, current_user_url).deliver }
      @talk.email_sent = true
    elsif @talk.accepted?
      @talk.speakers.each { |speaker| BoosterMailer.talk_acceptance_confirmation(@talk, speaker.user, current_user_url).deliver }
      @talk.email_sent = true
    else
      flash[:error] = "Cannot send email for talk '#{@talk.title}': Talk not accepted/refused yet!"
      redirect_to :controller => :acceptances
      return
    end

    @talk.save
    flash[:notice] = "Sendt mail om '#{@talk.title}'"
    redirect_to :controller => :acceptances
  end
end