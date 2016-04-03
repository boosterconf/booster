namespace :infomail do

  task :mail_settings => :environment do
    #include ActionDispatch::Routing::UrlFor
    #include ActionController::UrlWriter
    #default_url_options[:host] = 'rootsconf.no'
  end

  Rails.application.routes.default_url_options[:host]= 'boosterconf.no'

  task :sent_email do
    raise "This email has already been sent!"
  end

  task :unready_email do
    raise "This email is not ready to be sent yet!"
  end

  desc "Send out information about a related event"
  task :send_promo_mail => :sent_email do
    users = User.all.select { |u| u.accept_optional_email?  && u.hometown.downcase == 'bergen' }
    for user in users
      #next unless user.email == 'karianne.berg@gmail.com'
      print "Mailing: #{user.email}..."
      BoosterMailer.deliver_promo_email(user)
      puts " done"
    end
    puts "Sent all #{users.count} mails"
  end

  desc "Send out request for speakers to upload slides"
  task :upload_slides_notification => :sent_email do
    talks = Talk.all_accepted_lightning_talks
    talks.each do |talk|
      #next unless talk.speaker_email == 'karianne.berg@gmail.com'
      print "Mailing: #{talk.speaker_emails} #{talk.title}....."
      BoosterMailer.deliver_upload_slides_notification(talk, edit_talk_url(talk), new_password_reset_url)
      puts " done"
    end
    puts "Sent all #{talks.count} mails"
  end

  desc "Send out request for dinner attendance update"
  task :update_dinner_attendance => :sent_email do
    users = User.all_but_invited_speakers
    puts "Sending #{users.size} mails requesting to update dinner attendance"
    users.each do |user|
      #next unless user.email == 'karianne.berg@gmail.com'

      puts "Mailing to #{user.email}"
      BoosterMailer.update_dinner_attendance_status(user.first_name, user.email,
                                                            "http://www.boosterconf.no/users/current/attending_dinner",
                                                            "http://www.boosterconf.no/users/current/not_attending_dinner",
                                                            Rails.application.routes.url_helpers.new_password_reset_url).deliver
    end
    puts "Sent all #{users.size} mails"
  end

  desc "Send out information about tutorial registration"
  task :tutorial_registration => :sent_email do
    users = User.all_but_invited_speakers
    puts "Sending #{users.size} mails requesting to register for tutorials"
    users.each do |user|
      #next unless user.email == 'karianne.berg@gmail.com'

      puts "Mailing to #{user.email}"
      BoosterMailer.deliver_tutorial_registration(user, new_password_reset_url)
    end
    puts "Sent all #{users.size} mails"
  end

  desc "Send out information before the conference starts"
  task :welcome_to_the_conference => :sent_email do
    users = User.all
    for user in users
      #next unless user.email == 'karianne.berg@gmail.com'
      #next if not user.registration.registration_complete?

      print "Mailing: #{user.email}..."
      BoosterMailer.deliver_welcome_email(user, tutorial_registration_url)
      puts " done"
    end
    puts "Sent all #{users.count} mails"
  end


  desc "Send out information about hotel booking and program"
  task :hotel_program_email => :sent_email do
    users = User.all

    for user in users
      #next unless user.email == 'karianne.berg@gmail.com'
      print "Mailing: #{user.email}...\n"
      BoosterMailer.deliver_hotel_program_email(user)
    end
  end

  desc "Send out information to tutorial speakers about the speaker's dinner"
  task :speakers_dinner => :sent_email do
    users = User.all_accepted_speakers

    for user in users
      print "Mailing: #{user.email}...\n"
      next unless user.email.start_with? 'karianne.berg'
      BoosterMailer.speakers_dinner_email(user).deliver
    end

    puts "Sent all #{users.count} mails"
  end

  desc "Send out information to previous participants about early bird"
  task :previous_participants => :sent_email do
    users = User.all_normal_participants

    for user in users
      #next unless user.email == 'karianne.berg@gmail.com'
      print "Mailing: #{user.email}...\n"
      BoosterMailer.deliver_reminder_to_earlier_participants_email(user)
    end

    puts "Sent all #{users.count} mails"
  end

desc "Send out information to previous speaker about early bird"
  task :previous_speakers => :sent_email do
    users = User.all_speakers

    for user in users
      #next unless user.email.start_with? 'karianne.berg'
      print "Mailing: #{user.email}...\n"
      BoosterMailer.deliver_reminder_to_earlier_speakers_email(user)
    end

    puts "Sent all #{users.count} mails"
  end

  desc "Send out information to partners before the conference"
  task :sponsor_reminder => :sent_email do
    sponsors = Sponsor.all_accepted

    for sponsor in sponsors
      #next unless sponsor.email.start_with? 'karianne.berg'
      print "Mailing: #{sponsor.email}...\n"
      BoosterMailer.reminder_to_sponsor(sponsor).deliver
    end

    puts "Sent all #{sponsors.count} mails"
  end

  desc "Remind unfinished speakers to send in their proposal"
  task :unfinished_speaker_reminder => :mail_settings do
    speakers = User.joins(:registration).where("registrations.ticket_type_old IN (?)", ["lightning", "speaker"])
    unfinished = speakers.select { |speakers| speakers.talks.count == 0 }.reject(&:invited?)
    unfinished.each do |user|
      print "Mailing: #{user.email}...\n"
      BoosterMailer.reminder_to_unfinished_speakers(user).deliver
    end
  end
end
