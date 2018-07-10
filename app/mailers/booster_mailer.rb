class BoosterMailer < ApplicationMailer

  FROM_EMAIL = 'Booster conference <kontakt@boosterconf.no>'
  SUBJECT_PREFIX = "[boosterconf]"
  FIKEN_EMAIL = AppConfig.fiken_email

  def registration_confirmation(user)
    @name = user.first_name
    @email = user.email
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} User #{user.email} registered")
  end

  def manual_registration_confirmation(user)
    @name = user.first_name
    @email = user.email
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} User #{user.email} registered")
  end

  def manual_registration_notification(user, user_url)
    @name = user.full_name
    @email = user.email
    @description = user.registration.description
    @user_url = user_url
    mail(:to => FROM_EMAIL, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} User #{user.email} registered with manual payment method")
  end

  def speaker_registration_confirmation(user)
    @name = user.first_name
    @email = user.email
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} User #{user.email} registered")
  end

  def speaker_registration_notification(user, user_url)
    @name = user.full_name
    @email = user.email
    @user_url = user_url
    mail(:to => user.email, :subject => "#{SUBJECT_PREFIX} User #{user.email} registered as speaker")
  end

  def password_reset_instructions(user)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :from => FROM_EMAIL,
         :subject => "#{SUBJECT_PREFIX} How to change your password")

  end

  def free_registration_confirmation(user)
    @name = user.first_name
    @email = user.email
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} User #{user.email} free ticket request")
  end

  def free_registration_notification(admin, user, user_url)
    @name = user.full_name
    @email = user.email
    @description = user.registration.description
    @user_url = user_url
    mail(:to => admin.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} User #{user.email} was registered as #{user.registration.description}")
  end

  def free_registration_completion(user)
    @name = user.first_name
    @email = user.email
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} User #{user.email} free ticket confirmation")
  end
  
  def talk_confirmation(speaker, talk, talk_url)
    @speaker = speaker.first_name
    @email = speaker.email
    @talk = talk.title
    @talk_url = talk_url
    mail(:to => @email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} Confirmation on submission #{talk.title}")
  end

  def comment_notification(comment, comment_url)
    @speaker = comment.talk.speaker_name
    @talk = comment.talk.title
    @comment_url = comment_url
    mail(:to => comment.talk.users.map(&:email), :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} Comment for #{comment.talk.title}")
  end

  def talk_acceptance_confirmation(talk, speaker, current_user_url)
    @talk = talk
    @speaker = speaker
    @current_user_url = current_user_url
    mail(:to => speaker.email,
         :cc => FROM_EMAIL,
         :from => FROM_EMAIL,
         :subject => "#{SUBJECT_PREFIX} Your submission \"#{talk.title}\" has been accepted"
    )
  end

  def talk_refusation_confirmation(talk, speaker, current_user_url)
    @talk = talk
    @speaker = speaker
    @current_user_url = current_user_url
    mail(:to => speaker.email,
         :cc => FROM_EMAIL,
         :from => FROM_EMAIL,
         :subject => "#{SUBJECT_PREFIX} Your submission \"#{talk.title}\" has not been accepted")
  end

  def upload_slides_notification(talk, edit_talk_url, new_password_reset_url)
    @talk = talk.title
    @speaker_email = talk.speaker_emails
    @speaker = talk.speaker_name
    @edit_talk_url = edit_talk_url
    @new_password_reset_url = new_password_reset_url
    mail(:to => talk.users.map(&:email),
         :from => FROM_EMAIL,
         :cc => FROM_EMAIL,
         :subject => "You may now upload the slides for your lightning talk at the Booster conference website")
  end

  def update_dinner_attendance_status(name, email, attending_dinner_url, not_attending_dinner_url, lost_password_url)
    @name = name
    @attending_dinner_url = attending_dinner_url
    @not_attending_dinner_url = not_attending_dinner_url
    @lost_password_url = lost_password_url
    mail(:to => email, :from => FROM_EMAIL, :subject => "Please confirm your status regarding the conference dinner")
  end

  def welcome_email(user)
    @user = user
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "Welcome to Booster #{Dates::CONFERENCE_YEAR} at Scandic Hotel Bergen City, Wednesday March 13.")
  end

  def promo_email(user)
    @user = user
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "[Booster] Bergen Coding Dojo har startet opp!")
  end

  def error_mail(title, body)
    @body = body
    mail(to: "kontakt@boosterconf.no", from: FROM_EMAIL, subject: title)
  end

  def hotel_program_email(user)
    @user = user
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} Hotel booking and program")
  end

  def tutorial_registration(user, lost_password_url)
    @user = user
    @lost_password_url = lost_password_url
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "#{SUBJECT_PREFIX} Tutorial registration opens Friday May 20 09:00 AM")
  end

  def review_created(review, recipient)
    @reviewer = review.reviewer
    @talk = review.talk
    @review = review
    @talk_url = talk_url(@talk, anchor: 'all-reviews')
    mail(to: recipient,
         from: FROM_EMAIL,
         cc: FROM_EMAIL,
         subject: "#{SUBJECT_PREFIX} New review on talk '#{@talk.title}'")
  end

  def speakers_dinner_email(user)
    @user = user
    mail(:to => user.email, :cc => FROM_EMAIL, :from => FROM_EMAIL,
         :subject => "#{SUBJECT_PREFIX} Information about the speaker's dinner")
  end

  def initial_sponsor_mail(sponsor)
    @sender = sponsor.user
    @sponsor = sponsor
    mail(:to => sponsor.email, :from => "#{sponsor.user.full_name} <#{sponsor.user.email}>",
         :cc => FROM_EMAIL, :bcc => sponsor.user.email,
         :subject => "Bli partner med Booster #{Dates::CONFERENCE_YEAR}")
  end

  def additional_speaker(primary_speaker, additional_speaker, talk)
    @primary_speaker = primary_speaker
    @talk = talk
    @create_user_url = user_from_reference_url(additional_speaker.registration.unique_reference)

    mail(:to => additional_speaker.email,
         :from => FROM_EMAIL,
         :cc => FROM_EMAIL,
         :subject => "#{SUBJECT_PREFIX} You have been added as a speaker to a workshop")
  end

  def ticket_assignment(ticket)
    @name = ticket.name
    @reference = ticket.reference
    mail(:to => ticket.email,
         :from => FROM_EMAIL,
         :cc => FROM_EMAIL,
         :subject => "#{SUBJECT_PREFIX} You have been assigned a ticket to Booster #{Dates::CONFERENCE_YEAR}")
  end

  def reminder_to_sponsor(sponsor)
    @sponsor = sponsor

    mail(:to => sponsor.email,
         :from => FROM_EMAIL,
         :cc => FROM_EMAIL,
         :subject => "Booster #{Dates::CONFERENCE_YEAR} - viktig informasjon til partnere!")
  end

  def organizer_notification(text)
    @text = text

    mail(:to => FROM_EMAIL,
         :from => FROM_EMAIL,
         :subject => "Booster webapp organizer notification - take action!")
  end

  def reminder_to_earlier_participants_email(user)
    @name = user.full_name
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "Remember to sign up for Booster #{Dates::CONFERENCE_YEAR} before the Early Bird deadline!")
  end

  def reminder_to_earlier_speakers_email(user)
    @name = user.full_name
    mail(:to => user.email, :from => FROM_EMAIL, :subject => "Share your knowledge at Booster #{Dates::CONFERENCE_YEAR}!")
  end

  def reminder_to_unfinished_speakers(user)
    @name = user.first_name
    mail(to: user.email,
         from: FROM_EMAIL,
         subject: "Remember to send in your proposal",
         cc: FROM_EMAIL
    )
  end

  def ticket_confirmation_paid(ticket)
    @ticket = ticket
    mail(to: ticket.email, from: FROM_EMAIL,
         subject: "Your ticket to Booster is confirmed",
         cc: FROM_EMAIL)
  end

  def ticket_confirmation_invoice(ticket)
    @name = ticket.name
    @amount_due = ticket.ticket_type.price_with_vat
    @email = ticket.email
    @ticket = ticket
    mail(to: ticket.email, from: FROM_EMAIL,
         subject: "Your ticket to Booster is confirmed",
         cc: FROM_EMAIL)
  end

  def ticket_confirmation_speakers_and_organizers(ticket)
    @name = ticket.name
    @email = ticket.email
    @ticket = ticket
    mail(to: ticket.email, from: FROM_EMAIL,
         subject: "Your ticket to Booster is confirmed",
         cc: FROM_EMAIL)
  end

  def invoice_to_fiken(tickets, stripe_charge, invoice_details)
    @tickets = tickets
    @stripe_charge = stripe_charge
    @invoice_details = invoice_details
    mail(to: FIKEN_EMAIL, from: FROM_EMAIL,
         subject: "Invoice details Booster tickets")
  end

  def send_sponsor_ticket_link(sponsor, tickets)
    @tickets = tickets
    @sponsor = sponsor
    mail(to: sponsor.email, from: FROM_EMAIL,
         subject: "Booster partnerbilletter")
  end

  def send_ticket_link(ticket)
    @ticket = ticket
    mail(to: ticket.email, from: FROM_EMAIL,
         subject: "Booster conference dinner confirmation")
  end

end
