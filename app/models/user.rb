class User < ApplicationRecord
  acts_as_paranoid
  has_one :ticket
  has_one :bio, autosave: true
  has_many :speakers
  has_many :talks, :through => :speakers

  accepts_nested_attributes_for :bio

  acts_as_authentic do |c|
    c.login_field = :email
    c.validate_login_field = false
  end

  validates_presence_of :phone_number, :message => "You have to specify a phone number"
  validates_presence_of :first_name, :message => "You have to specify a first name."
  validates_presence_of :last_name, :message => "You have to specify a last name."
  validates_presence_of :company, :message => "You have to specify a company."

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

  def user_status
    registration ? registration.description : "Unknown"
  end

  def has_role?(role)
    roles && roles.include?(role)
  end

  def roles_description
    if roles
      roles.split(",").map {|r| Roles.label[r.to_sym]}.join(", ")
    else
      ""
    end
  end

  def talks_this_year
    talks.select {|talk| talk.year == AppConfig.year}
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    BoosterMailer.password_reset_instructions(self).deliver_now
  end

  def confirmed_speaker?
    self.has_accepted_lightning_talk? || self.has_accepted_tutorial?
  end

  def invite_speaker
    self.build_registration unless self.registration
    self.registration.registration_complete = true
  end

  def has_accepted_or_pending_tutorial?
    tutorials = self.talks.find_all {|talk| talk.is_workshop? && (talk.accepted? || talk.pending?)}
    !tutorials.empty?
  end

  def has_accepted_lightning_talk?
    talks = self.talks.find_all {|talk| talk.is_lightning_talk? && talk.accepted?}
    !talks.empty?
  end

  def has_accepted_tutorial?
    talks = self.talks.find_all {|talk| talk.is_workshop? && talk.accepted?}
    !talks.empty?
  end

  def has_accepted_talk?
    talks = self.talks.find_all {|talk| talk.accepted?}
    !talks.empty?
  end

  def has_confirmed_talk?
    talks = self.talks.find_all {|talk| talk.confirmed?}
    !talks.empty?
  end

  def has_all_talks_refused?
    refused_talks = self.talks.find_all {|talk| talk.refused?}
    self.talks.size == refused_talks.size
  end

  def has_all_tutorials_refused?
    refused_tutorials = self.talks.find_all {|talk| talk.refused? && talk.is_workshop?}
    all_tutorials = self.talks.find_all {|talk| talk.is_workshop?}
    all_tutorials.size == refused_tutorials.size
  end

  def has_pending_or_accepted_talk?
    talks = self.talks.find_all {|talk| (talk.is_lightning_talk? || talk.is_short_talk?) && (talk.accepted? || talk.pending?)}
    !talks.empty?
  end

  def update_to_lightning_talk_speaker
    self.build_registration unless self.registration
    self.registration.ticket_type = TicketType.lightning
  end

  def update_to_paying_user
    self.build_registration unless self.registration
    if self.registration.ticket_type.speaker?
      if self.is_early_bird?
        self.registration.ticket_type = TicketType.early_bird
      else
        self.registration.ticket_type = TicketType.full_price
      end
    end
  end

  def is_early_bird?
    self.build_registration unless self.registration
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
    all_talks = []
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
    self.all.select {|u| u.has_accepted_talk? || u.invited == true}
  end

  def self.all_confirmed_speakers
    self.all.includes(:talks).select {|u| u.has_confirmed_talk? || u.invited == true}
  end

  def self.all_tutorial_speakers
    self.all.select {|u| u.has_accepted_tutorial?}
  end

  def self.all_lightning_speakers
    self.all.select {|u| u.has_accepted_lightning_talk?}
  end

  def self.all_organizers
    User.includes(:registration).to_a.select {|u| u.registration != nil && u.registration.ticket_type.reference == 'organizer'}
  end

  def self.all_organizers_and_volunteers
    User.includes(:registration).to_a.select {|u| u.registration != nil && (['organizer', 'volunteer'].include? u.registration.ticket_type.reference)}
  end

  def self.featured_speakers
    speakers = Rails.cache.fetch("featured_speakers", expires_in: 30.minute) do
      potential_speakers = User.includes(:bio).where(featured_speaker: true).order('created_at DESC')
      speakers = []
      potential_speakers.each do |sp|
        if sp.is_featured? && sp.bio.picture.present?
          speakers << sp
        end
      end
      speakers
    end
    speakers
  end

  def self.featured_organizers
    User.where(:feature_as_organizer => true).joins(:bio).includes(:bio)
  end

  def self.all_normal_participants
    User.includes(:registration).to_a.select {|u| u.registration != nil && u.registration.ticket_type.normal_ticket?}
  end

  def self.all_participants
    User.includes(:registration).to_a
  end

  def self.all_speakers
    User.includes(:registration).to_a.select {|u| u.registration != nil && u.registration.ticket_type.speaker?}
  end

  def self.create_unfinished(email, first_name = nil, last_name = nil)
    user = User.new
    user.email = email.present? ? email : ""
    user.first_name = first_name if first_name.present?
    user.last_name = last_name if last_name.present?
    user.password = SecureRandom.urlsafe_base64 # må sette passord, av grunner bare authlogic forstår
    user.skeleton_user_registration_finished = false
    user.unique_reference = SecureRandom.urlsafe_base64
    user.save(:validate => false)
    user.create_bio
    user
  end

  def talks
    Talk.unscoped {super}
  end

  def self.all_from_ticket_email
    User.find_by_sql("SELECT * FROM
  (SELECT * FROM users INNER JOIN bios ON users.id = bios.user_id) as foo
  INNER JOIN tickets ON foo.email=tickets.email")
  end
end
