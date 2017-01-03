class AcceptancesController < ApplicationController

  before_filter :require_admin, except: [:could_not_attend, :confirm]
  before_filter :require_admin_or_talk_owner, only: [:could_not_attend, :confirm]

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
    @talk.save
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' accepted."
  end

  def refuse
    @talk = Talk.find_by_id(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    @talk.refuse!
    @talk.save!
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' refused."
  end

  def pending
    @talk = Talk.find_by_id(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    @talk.regret! #Set to pending :)
    @talk.save
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' put on hold."
  end

  def could_not_attend
    @talk = Talk.find_by_id(params[:id])

    @talk.could_not_attend!
    @talk.speakers_confirmed = false
    @talk.save!
    @talk.update_speakers!(current_user)

    return render :thanks unless current_user.is_admin?

    redirect_to acceptances_path, notice: "#{@talk.speaker_name}'s talk '#{@talk.title}' set to status 'could not attend'"
  end

  def confirm
    @talk = Talk.find_by_id(params[:id])

    unless @talk.accepted?
      return redirect_to acceptances_path, error: "Cannot confirm speaker on talk that is not accepted"
    end

    @talk.speakers_confirmed = true
    @talk.save
    @talk.update_speakers!(current_user)


    return render :thanks unless current_user.is_admin?

    redirect_to acceptances_path, notice: "#{@talk.speaker_name} confirmed for talk '#{@talk.title}'"
  end

  def unconfirm
    @talk = Talk.find_by_id(params[:id])

    unless @talk.speakers_confirmed?
      redirect_to acceptances_path, error: "Cannot cancel speaker that is not confirmed"
    end

    @talk.speakers_confirmed = false
    @talk.save
    @talk.update_speakers!(current_user)

    redirect_to acceptances_path, notice: "#{@talk.speaker_name} cancelled for talk '#{@talk.title}'"
  end

  def send_mail
    @talk = Talk.find_by_id(params[:id])

    return redirect_on_email_sent if @talk.email_sent

    if @talk.refused?
      @talk.speakers.each { |speaker| BoosterMailer.talk_refusation_confirmation(@talk, speaker.user, current_user_url).deliver_now }
    elsif @talk.accepted?
      @talk.speakers.each { |speaker| BoosterMailer.talk_acceptance_confirmation(@talk, speaker.user, current_user_url).deliver_now }
    else
      return redirect_to acceptances_path, error: "Cannot send email for talk '#{@talk.title}': Talk not accepted/refused yet!"
    end

    @talk.email_sent = true
    @talk.save

    redirect_to acceptances_path, notice: "Sent mail about '#{@talk.title}'"
  end

  def create_tickets
    talks = Talk.all_with_speakers.where(acceptance_status: 'accepted', speakers_confirmed: true)
    talks.each { |talk|
      talk.users.each { |user|
        unless (Ticket.has_ticket(user.email))
          ticket = Ticket.new
          ticket.ticket_type = user.registration.ticket_type
          ticket.attend_dinner = true
          ticket.roles = user.roles
          ticket.dietary_info = user.dietary_requirements
          ticket.name = "#{user.first_name} #{user.last_name}"
          ticket.company = user.company
          ticket.email = user.email
          ticket.save!

          if (ticket.ticket_type.paying_ticket?)
            BoosterMailer.ticket_confirmation_invoice(ticket).deliver_now
            BoosterMailer.invoice_to_fiken(InvoicePdf.generate([ticket], nil,
                                                               {   :payment_email => ticket.email,
                                                                   :payment_info => ticket.ticket_type.name,
                                                                   :payment_zip => user.zip})
            ).deliver_now
          end
        end
      }
    }
    redirect_to acceptances_path, notice: 'Created tickets for confirmed speakers'
  end

  private
  def redirect_on_email_sent
    redirect_to acceptances_path, error: "Cannot send email for talk '#{@talk.title}': Email already sent!"
  end

  #TODO: Temp method, delete this
  def load_talk(id)
    Talk.includes(users: [{ registration: [:ticket_type]}]).find(id)
  end
end
