class User < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :accept_optional_email, :accepted_privacy_guidelines, :birthyear, :company, :crypted_password,
                  :current_login_at, :current_login_ip, :description, :dietary_requirements, :email,
                  :password, :password_confirmation, :city, :zip,
                  :failed_login_count, :feature_as_organizer, :featured_speaker, :gender, :hometown,
                  :invited, :is_admin, :last_login_at, :last_request_at, :login_count,
                  :password_salt, :perishable_token, :persistence_token, :phone_number, :registration_ip, :roles,
                  :registration_attributes, :bio_attributes, :first_name, :last_name, :hear_about

  has_one :registration, autosave: true
  has_one :bio, autosave: true
  has_many :speakers
  has_many :talks, :through => :speakers

  accepts_nested_attributes_for :registration, :bio

  default_scope { includes({registration: [:ticket_type]}).order('users.created_at desc')}

  acts_as_authentic do |c|
    c.login_field = :email
    c.validate_login_field = false
  end

  validates_presence_of :phone_number, :message => "You have to specify a phone number"
  validates_presence_of :first_name, :message => "You have to specify a first name."
  validates_presence_of :last_name, :message => "You have to specify a last name."
  validates_presence_of :company, :message => "You have to specify a company."

  # A user always has a registration, so no more null checks
  after_initialize { |user| user.build_registration unless user.registration }

  def full_name
    if read_attribute(:first_name)
      (read_attribute(:first_name) or "") + ' ' + (read_attribute(:last_name) or "")
    else
      'unnamed'
    end
  end

  def unnamed?
    full_name == 'unnamed'
  end

  def name_or_email
    if unnamed?
      email
    else
      full_name
    end
  end

  def attending_speakers_dinner(will_attend)
    self.registration.speakers_dinner = will_attend
    save!
  end

  def attending_dinner?
    self.registration ? self.registration.includes_dinner? : false
  end

  def attend_dinner(have_dinner)
    self.registration.includes_dinner = have_dinner if self.registration
    save!
  end

  def attending_dinner!
    attend_dinner(true)
  end

  def not_attending_dinner!
    attend_dinner(false)
  end

  def user_status
    registration ? registration.description : "Unknown"
  end

  def has_role?(role)
    roles && roles.include?(role)
  end

  def roles_description
    if roles
      roles.split(",").map { |r| Roles.label[r.to_sym] }.join(", ")
    else
      ""
    end
  end

  def talks_this_year
    talks.select { |talk| talk.year == AppConfig.year }
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    BoosterMailer.password_reset_instructions(self).deliver_now
  end

  def confirmed_speaker?
    self.has_accepted_lightning_talk? || self.has_accepted_tutorial?
  end

  def invite_speaker
    self.registration.registration_complete = true
    self.registration.ticket_type_old = 'speaker'
    self.registration.ticket_type = TicketType.speaker
    self.registration.manual_payment = false
  end

  def update_ticket_type!(current_user='Unknown')
    unless self.registration.special_ticket?
      if self.has_accepted_or_pending_tutorial?
        self.registration.ticket_type_old = 'speaker'
        self.registration.ticket_type = TicketType.speaker
      elsif self.has_all_tutorials_refused? && self.has_pending_or_accepted_talk?
        self.update_to_lightning_talk_speaker
      elsif self.has_all_talks_refused?
        self.update_to_paying_user
      end

      if self.has_accepted_tutorial?
        unless self.registration.registration_complete?
          self.registration.registration_complete = true
          self.registration.completed_by = current_user.email
        end
      else
        self.registration.registration_complete = false
        self.registration.completed_by = ""
      end

      self.registration.update_price
      self.registration.save
    end
  end

  def has_accepted_or_pending_tutorial?
    tutorials = self.talks.find_all { |talk| talk.is_workshop? && (talk.accepted? || talk.pending?) }
    !tutorials.empty?
  end

  def has_accepted_lightning_talk?
    talks = self.talks.find_all { |talk| talk.is_lightning_talk? && talk.accepted? }
    !talks.empty?
  end

  def has_accepted_tutorial?
    talks = self.talks.find_all { |talk| talk.is_workshop? && talk.accepted? }
    !talks.empty?
  end

  def has_accepted_talk?
    talks = self.talks.find_all { |talk| talk.accepted? }
    !talks.empty?
  end

  def has_all_talks_refused?
    refused_talks = self.talks.find_all { |talk| talk.refused? }
    self.talks.size == refused_talks.size
  end

  def has_all_tutorials_refused?
    refused_tutorials = self.talks.find_all { |talk| talk.refused? && talk.is_workshop? }
    all_tutorials = self.talks.find_all { |talk| talk.is_workshop? }
    all_tutorials.size == refused_tutorials.size
  end

  def has_pending_or_accepted_talk?
    talks = self.talks.find_all { |talk| (talk.is_lightning_talk? || talk.is_short_talk?) && (talk.accepted? || talk.pending?) }
    !talks.empty?
  end

  def update_to_lightning_talk_speaker
    self.registration.ticket_type_old = 'lightning'
    self.registration.ticket_type = TicketType.lightning
  end


  def update_to_paying_user
    if self.registration.ticket_type.speaker?
      if self.is_early_bird?
        self.registration.ticket_type_old = 'early_bird'
        self.registration.ticket_type = TicketType.early_bird
      else
        self.registration.ticket_type_old = 'full_price'
        self.registration.ticket_type = TicketType.full_price
      end
    end
  end

  def is_early_bird?
    self.registration.created_at < AppConfig.early_bird_ends
  end

  def is_featured?
    read_attribute(:featured_speaker) && bio != nil
  end

  def is_organizer_with_bio?
    read_attribute(:feature_as_organizer) && bio != nil
  end

  def feature_as_speaker
    write_attribute(:featured_speaker, true)
  end

  def is_on_twitter?
    bio.twitter_handle && bio.twitter_handle.length > 0
  end

  def has_blog?
    bio.blog && bio.blog.length > 0
  end

  def has_all_statistics?
    self.gender != nil && self.birthyear != nil
  end

  def accepted_talks
    all_talks =[]
    talks.each do |talk|
      all_talks << talk if (talk) and (talk.accepted?)
    end
    all_talks
  end

  def atomic_reference
    name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

  def has_valid_email?
    email.match(Authlogic::Regex.email)
  end

  def self.find_by_email(email)
   self.where('lower(email) = ?', email.downcase).first
  end

  def self.all_but_invited_speakers
    User.where(invited: false)
  end
  
  def self.all_accepted_speakers
    self.all.select { |u| u.has_accepted_talk? || u.invited == true }
  end

  def self.all_tutorial_speakers
    self.all.select { |u| u.has_accepted_tutorial? }
  end

  def self.all_lightning_speakers
    self.all.select { |u| u.has_accepted_lightning_talk? }
  end

  def self.all_organizers
    User.includes(:registration).to_a.select {|u| u.registration.ticket_type_old == 'organizer'}
  end

  def self.all_organizers_and_volunteers
    User.includes(:registration).to_a.select {|u| ['organizer', 'volunteer'].include? u.registration.ticket_type_old}
  end

  def self.featured_speakers
    potential_speakers = User.includes(:bio, :talks).where(featured_speaker: true).order('created_at DESC')
    speakers = []
    potential_speakers.each do |sp|
      if sp.is_featured?
        speakers << sp
      end
    end
    speakers
  end

  def self.featured_organizers
    User.where(:feature_as_organizer => true).joins(:bio).includes(:bio)
  end

  def self.all_normal_participants
    User.includes(:registration).to_a.select {|u| %w(early_bird full_price sponsor organizer reviewer).include? u.registration.ticket_type_old }
  end

  def self.all_participants
    User.includes(:registration).to_a
  end

  def self.all_speakers
      User.includes(:registration).to_a.select {|u| %w(lightning speaker).include? u.registration.ticket_type_old }
  end

  def self.create_unfinished(email, ticket_type, first_name=nil, last_name=nil)
    user = User.new
    user.build_registration
    user.email = email.present? ? email : ""
    user.first_name = first_name if first_name.present?
    user.last_name = last_name if last_name.present?
    user.password = SecureRandom.urlsafe_base64 # må sette passord, av grunner bare authlogic forstår
    user.registration.ticket_type_old = ticket_type
    user.registration.manual_payment = true
    user.registration.includes_dinner = true
    user.registration.unfinished = true
    user.registration.unique_reference = SecureRandom.urlsafe_base64
    user.create_bio
    user
  end

  def talks
    Talk.unscoped { super }
  end

end
