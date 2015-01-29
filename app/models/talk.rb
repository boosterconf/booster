class Talk < ActiveRecord::Base
  default_scope :order => 'talks.created_at desc'

  attr_accessible :talk_type, :talk_type_id, :language, :title, :description, :audience_level, :max_participants,
                  :participant_requirements, :equipment, :room_setup, :accepted_guidelines, :acceptance_status,
                  :slide, :outline, :appropriate_for_roles, :speakers_confirmed, :speaking_history

  has_many :speakers
  has_many :users, :through => :speakers
  has_many :comments, :order => 'created_at', :include => :user
  has_and_belongs_to_many :tags
  belongs_to :talk_type
  has_many :reviews, order: 'created_at desc', include: :reviewer
  has_attached_file :slide, PAPERCLIP_CONFIG
  has_many :slots
  has_many :periods

  validates_attachment_content_type :slide,
                                    :content_type => [
                                        'application/pdf',
                                        'application/vnd.ms-powerpoint',
                                        'application/ms-powerpoint',
                                        %r{application/vnd.openxmlformats-officedocument},
                                        %r{application/vnd.oasis.opendocument},
                                        'application/zip',
                                        'application/x-7z-compressed',
                                        'application/x-gtar'
                                    ]

  validates_attachment_size :slide, :less_than => 50.megabytes

  validates :title, presence: true
  validates :description, presence: true
  validates :language, presence: true
  validates :talk_type_id, presence: true
  
  after_initialize do |talk|
    talk.acceptance_status ||= 'pending'
    talk.year = AppConfig.year
  end

  def speaker_name
    SpeakerName.new(self.users)
  end

  def speaker_emails
    users.map(&:email).join(', ')
  end

  def is_presented_by?(speaker)
    users.include?(speaker)
  end

  def accept!
    self.acceptance_status = 'accepted'
    self
  end

  def accepted?
    self.acceptance_status == 'accepted'
  end

  def pending?
    self.acceptance_status == 'pending'
  end

  def refused?
    self.acceptance_status == 'refused'
  end

  def refuse!
    self.acceptance_status = 'refused'
    self
  end

  def regret!
    self.acceptance_status = 'pending'
    self
  end

  def is_lightning_talk?
    # TODO: Megahack!
    return false unless talk_type
    talk_type.name == 'Lightning talk'
  end

  def is_tutorial?
    !is_lightning_talk?
  end

=begin
  def is_full?
    participants.size >= max_participants
  end
=end

  def update_speakers(current_user)
    for speaker in self.users
      speaker.update_ticket_type!(current_user)
    end
  end

  def is_in_one_of_these(periods)
    self.periods.each { |period|
      if periods.include? period
        return true
      end
    }
    false
  end

  def start_time
    periods.sort! { |first, second| first.start_time <=> second.start_time }.first.start_time
  end

  def end_time
    periods.sort! { |first, second| first.end_time <=> second.end_time }.last.end_time
  end

  def is_scheduled?
    periods.present? && periods.length > 0
  end

  def appropriate_for_role?(role)
    self.appropriate_for_roles && self.appropriate_for_roles.include?(role)
  end

  def has_been_reviewed_by(user)
    reviews.map(&:reviewer).include?(user)
  end

  def invited?
    self.users.any?(&:invited)
  end

  def self.all_pending_and_approved
    all(order: 'acceptance_status, id desc', include: :reviews).select {
        |t| !t.refused? && !t.users.first.nil? && t.year == AppConfig.year
    }
  end

  def self.all_accepted
    all(include: [:slots, :users => :registration], conditions: "acceptance_status = 'accepted'")
  end

  def self.all_accepted_tutorials
    unscoped.all(include: [:talk_type], conditions: ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 't'"], :order => "title")
  end

  def self.all_accepted_lightning_talks
    all(include: :talk_type, conditions: ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 'f'"], :order => "title ")
  end

  def self.all_with_speakers
    with_exclusive_scope { find(:all, include: :users, order: 'users.last_name ') }
  end

  def self.add_comment(talk_id, comment)
    comm = FeedbackComment.new
    comm.comment = comment
    comm.talk = Talk.find(talk_id)
    comm.save!
  end

  def self.count_accepted
    self.count(:conditions => "acceptance_status = 'accepted'")
  end

  def self.count_refused
    self.count(:conditions => "acceptance_status = 'refused'")
  end

  def self.count_pending
    self.count(:conditions => "acceptance_status = 'pending'")
  end

  def to_s
    "\"#{self.title}\" by #{self.speaker_name}"
  end

end
