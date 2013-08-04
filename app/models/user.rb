class User < ActiveRecord::Base
  attr_accessible :accept_optional_email, :accepted_privacy_guidelines, :birthyear, :company, :crypted_password,
                  :current_login_at, :current_login_ip, :description, :dietary_requirements, :email,
                  :password, :password_confirmation, :city, :zip,
                  :failed_login_count, :feature_as_organizer, :featured_speaker, :gender, :hometown,
                  :invited, :is_admin, :last_login_at, :last_request_at, :login_count, :member_dnd, :name,
                  :password_salt, :perishable_token, :persistence_token, :phone_number, :registration_ip, :role, :roles,
                  :registration_attributes, :bio_attributes

  has_one :registration
  has_one :bio
  has_many :speakers
  has_many :talks, :through => :speakers

  accepts_nested_attributes_for :registration, :bio

  default_scope :order => 'users.created_at desc'

  acts_as_authentic do |c|
    c.login_field = :email
  end


  validates_presence_of :phone_number, :message => "You have to specify a phone number"
  validates_presence_of :name, :message => "You have to specify a name."
  validates_presence_of :company, :message => "You have to specify a company."

  validates_each :accepted_privacy_guidelines do |record, attr, value|
    record.errors.add attr, 'You have to accept that we send you emails regarding the conference.' if value == false
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
    BoosterMailer.password_reset_instructions(self).deliver
  end

  def confirmed_speaker?
    self.has_accepted_lightning_talk? || self.has_accepted_tutorial?
  end

  def update_ticket_type!(current_user='Unknown')
    unless self.registration.special_ticket?
      if self.has_accepted_or_pending_tutorial?
        self.registration.ticket_type_old = 'speaker'
      elsif self.has_all_tutorials_refused? && self.has_pending_or_accepted_lightning_talk?
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
    tutorials = self.talks.find_all { |talk| talk.is_tutorial? && (talk.accepted? || talk.pending?) }
    !tutorials.empty?
  end

  def has_accepted_lightning_talk?
    talks = self.talks.find_all { |talk| talk.is_lightning_talk? && talk.accepted? }
    !talks.empty?
  end

  def has_accepted_tutorial?
    talks = self.talks.find_all { |talk| talk.is_tutorial? && talk.accepted? }
    !talks.empty?
  end

  def has_all_talks_refused?
    refused_talks = self.talks.find_all { |talk| talk.refused? }
    self.talks.size == refused_talks.size
  end

  def has_all_tutorials_refused?
    refused_tutorials = self.talks.find_all { |talk| talk.refused? && talk.is_tutorial? }
    all_tutorials = self.talks.find_all { |talk| talk.is_tutorial? }
    all_tutorials.size == refused_tutorials.size
  end

  def has_pending_or_accepted_lightning_talk?
    talks = self.talks.find_all { |talk| talk.is_lightning_talk? && (talk.accepted? || talk.pending?) }
    !talks.empty?
  end

  def update_to_lightning_talk_speaker
    self.registration.ticket_type_old = 'lightning'
  end


  def update_to_paying_user
    if self.registration.ticket_type_old == "speaker" || self.registration.ticket_type_old == "lightning"
      if self.is_early_bird?
        self.registration.ticket_type_old = 'early_bird'
      else
        self.registration.ticket_type_old = 'full_price'
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

  def has_all_statistics
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

  def self.find_with_filter(filter)
    case filter
      when "all", "", nil
        return find(:all, :include => :registration)
      when "admin"
        return find(:all, :conditions => {:is_admin => true}, :include => :registration)
      when "speakers"
        return find(:all, :include => [:registration, :talks]).reject { |u| u.talks.empty? }
      when "paid"
        return find(:all, :include => :registration).select { |u| u.registration and u.registration.paid? }
      when "unpaid"
        return find(:all, :include => :registration).select { |u| u.registration and not u.registration.paid? and u.talks.empty? }
      when "volunteer"
        return find(:all, :include => :registration).select { |u| u.registration and u.registration.ticket_type_old == "volunteer" }
      when "student"
        return find(:all, :include => :registration).select { |u| u.registration and (u.registration.ticket_type_old == "student" or u.registration.ticket_type_old == "mod251") }
      when "paying_speaker"
        return find(:all, :include => [:registration, :talks]).reject { |u| u.talks.empty? }.
            select { |u| u.registration and u.registration.paid? }
      else
        raise "Illegal filter #{filter}"
    end
  end

  def self.all_but_invited_speakers
    self.find_all_by_invited(false)
  end

  def self.all_invited_speakers
    self.find_all_by_invited(true)
  end


  def self.all_tutorial_speakers
    self.all.select { |u| u.has_accepted_tutorial? }
  end

  def self.all_lightning_speakers
    self.all.select { |u| u.has_accepted_lightning_talk? }
  end

  def self.all_organizers
    self.all(:include => :registration).select { |u| u.registration != NIL && u.registration.ticket_type_old == "organizer" }
  end

  def self.featured_speakers
    potential_speakers = all(:conditions => ['featured_speaker = ?', true], :include => [:bio, :talks],
                             :order => 'created_at DESC')
    speakers = []
    potential_speakers.each do |sp|
      if sp.is_featured?
        speakers << sp
      end
    end
    speakers
  end

  def self.all_normal_participants
    User.all(:conditions => ['registrations.ticket_type_old IN (?)', %w(early_bird full_price sponsor organizer)], :include => [:registration])
  end

  def self.all_speakers
    User.all(:conditions => ['registrations.ticket_type_old IN (?)', %w(lightning speaker)], :include => [:registration])
  end

  def self.create_unfinished(email, ticket_type, name=nil)
    user = User.new
    user.build_registration
    user.email = email.present? ? email : ""
    user.name = name if name.present?
    user.password = SecureRandom.urlsafe_base64  # må sette passord, av grunner bare authlogic forstår
    user.registration.ticket_type_old = ticket_type
    user.registration.includes_dinner = true
    user.registration.unfinished = true
    user.registration.unique_reference = SecureRandom.urlsafe_base64
    user
  end

end

