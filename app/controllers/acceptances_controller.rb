class AcceptancesController < ApplicationController

  before_action :require_admin, except: [:could_not_attend, :confirm]
  before_action :require_admin_or_talk_owner, only: [:could_not_attend, :confirm]

  def index
    @talks = Talk.all_with_speakers

    @types = {
        accepted_and_confirmed: Talk.count_accepted_and_confirmed,
        accepted: Talk.count_accepted,
        pending: Talk.count_pending,
        refused: Talk.count_refused,
        could_not_attend: Talk.could_not_attend
    }
  end

  def accept
    @talk = Talk.find_by_id(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    @talk.accept!
    save_talk_and_update_speaker(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' accepted."
  end

  def refuse
    @talk = Talk.find_by_id(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    @talk.refuse!
    save_talk_and_update_speaker(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' refused."
  end

  def pending
    @talk = Talk.find_by_id(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    @talk.regret! #Set to pending :)
    save_talk_and_update_speaker(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' put on hold."
  end

  def could_not_attend
    @talk = Talk.find_by_id(params[:id])

    @talk.could_not_attend!
    @talk.speakers_confirmed = false
    save_talk_and_update_speaker(current_user)

    return render :thanks unless current_user.is_admin?

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' set to status 'could not attend'"
  end

  def confirm
    @talk = Talk.find_by_id(params[:id])

    unless @talk.accepted?
      return redirect_to acceptances_path, error: "Cannot confirm speaker on talk that is not accepted"
    end

    @talk.speakers_confirmed = true
    save_talk_and_update_speaker(current_user)


    return render :thanks unless current_user.is_admin?

    redirect_to acceptances_path, notice: "#{@talk.speaker_name} confirmed for talk '#{@talk.title}'"
  end

  def unconfirm
    @talk = Talk.find_by_id(params[:id])

    unless @talk.speakers_confirmed?
      redirect_to acceptances_path, error: "Cannot cancel speaker that is not confirmed"
    end

    @talk.speakers_confirmed = false
    save_talk_and_update_speaker(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name} cancelled for talk '#{@talk.title}'"
  end

  def send_mail
    @talk = Talk.find_by_id(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    if @talk.refused?
      @talk.speakers.each {|speaker| BoosterMailer.talk_refusation_confirmation(@talk, speaker.user, current_user_url).deliver_now}
    elsif @talk.accepted?
      @talk.speakers.each {|speaker| BoosterMailer.talk_acceptance_confirmation(@talk, speaker.user, current_user_url).deliver_now}
    else
      return redirect_to acceptances_path, error: "Cannot send email for talk '#{@talk.title}': Talk not accepted/refused yet!"
    end

    @talk.email_sent = true
    @talk.save

    redirect_to acceptances_path, notice: "Sent mail about '#{@talk.title}'"
  end

  def create_tickets_organizers
    organizers = User.all_organizers
    organizers.each {|user|
      unless Ticket.has_ticket(user.email)
        ticket = Ticket.new
        ticket.ticket_type = TicketType.organizer
        ticket.attend_dinner = true
        ticket.roles = user.roles
        ticket.dietary_info = user.dietary_requirements
        ticket.name = "#{user.first_name} #{user.last_name}"
        ticket.company = user.company
        ticket.email = user.email
        ticket.reference = SecureRandom.urlsafe_base64
        ticket.save!
        BoosterMailer.ticket_confirmation_speakers_and_organizers(ticket).deliver_now
      end
    }
    redirect_to acceptances_path, notice: 'Created tickets for organizers'
  end

  def create_tickets
    talks = Talk.all_with_speakers.where(acceptance_status: 'accepted', speakers_confirmed: true)
    talks.each {|talk|
      talk.users.each {|user|
        unless Ticket.has_ticket(user.email)
          ticket = Ticket.new
          ticket.ticket_type = TicketType.speaker
          ticket.attend_dinner = true
          ticket.roles = user.roles
          ticket.dietary_info = user.dietary_requirements
          ticket.name = "#{user.first_name} #{user.last_name}"
          ticket.company = user.company
          ticket.email = user.email
          ticket.reference = SecureRandom.urlsafe_base64
          ticket.save!
          BoosterMailer.ticket_confirmation_speakers_and_organizers(ticket).deliver_now
        end
      }
    }
    invited = User.all.where(invited: true)
    invited.each {|user|
      unless Ticket.has_ticket(user.email)
        ticket = Ticket.new
        ticket.ticket_type = TicketType.speaker
        ticket.attend_dinner = true
        ticket.roles = user.roles
        ticket.dietary_info = user.dietary_requirements
        ticket.name = "#{user.first_name} #{user.last_name}"
        ticket.company = user.company
        ticket.email = user.email
        ticket.reference = SecureRandom.urlsafe_base64
        ticket.save!
        BoosterMailer.ticket_confirmation_speakers_and_organizers(ticket).deliver_now
      end
    }
    redirect_to acceptances_path, notice: 'Created tickets for confirmed speakers'
  end

  require 'csv'
  def download_speakers_list
    @speakers = []
    talks = Talk.all_with_speakers.where(acceptance_status: 'accepted', speakers_confirmed: true)
    talks.each {|talk|
      @speakers += talk.users
    }
    invited = User.all.where(invited: true)
    @speakers += invited

    data = CSV.generate do |csv|
      csv << User.column_names
      @speakers.each do |speaker|
        csv << speaker.attributes.values_at(*User.column_names)
      end
    end
    respond_to do |format|
      format.csv { send_data data }
    end
  end

  private
  def redirect_on_email_sent
    redirect_to acceptances_path, error: "Cannot send email for talk '#{@talk.title}': Email already sent!"
  end

  def save_talk_and_update_speaker user
    @talk.save
  end
end
