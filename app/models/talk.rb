class Talk < ApplicationRecord
  acts_as_paranoid

  has_many :speakers
  has_many :users, through: :speakers
  has_and_belongs_to_many :tags
  belongs_to :talk_type
  has_many :reviews, -> { order 'created_at desc'}
  has_attached_file :slide, PAPERCLIP_CONFIG
  has_and_belongs_to_many :slots, join_table: 'talk_positions'
  has_and_belongs_to_many :volunteers, join_table: 'talks_volunteers'

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

  def has_single_speaker?
    users.size == 1
  end

  def accept!
    self.acceptance_status = 'accepted'
    self
  end

  def accepted?
    self.acceptance_status == 'accepted'
  end

  def confirmed?
   self.acceptance_status == 'accepted' && self.speakers_confirmed == true
  end
  
  def pending?
    self.acceptance_status == 'pending'
  end

  def could_not_attend!
    self.acceptance_status = 'could_not_attend'
    self
  end

  def could_not_attend?
    self.acceptance_status == 'could_not_attend'
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
    talk_type.is_lightning_talk?
  end

  def is_workshop?
    talk_type.is_workshop
  end

  def is_short_talk?
    talk_type.is_short_talk?
  end

=begin
  def is_full?
    participants.size >= max_participants
  end
=end

  def is_in_one_of_these(periods)
    self.periods.each do |period|
      if periods.include? period
        return true
      end
    end
    false
  end

  def start_time
    periods = slots.map(&:period)
    periods.sort_by { |p| p.start_time }.first.start_time
  end

  def end_time
    periods.sort(&:end_time).last.end_time
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

  def status
    if invited?
      "invited"
    elsif speakers_confirmed?
      "accepted_and_confirmed"
    else
      acceptance_status
    end
  end

  def self.all_pending_and_approved
    self.includes(:talk_type,:users)
        .where(year: AppConfig.year)
        .where('acceptance_status != ?', 'refused')
        .order('acceptance_status, id desc')
  end

  def self.talks_for_review
    self.includes(:reviews,:talk_type)
        .where(year: AppConfig.year)
        .where('acceptance_status != ?', 'refused')
        .order('acceptance_status, id desc')
  end

  def self.all_accepted
    Talk.includes(:talk_type)
        .where(acceptance_status: 'accepted')
        .order('title')
        .to_a
  end

  def self.all_confirmed
    Talk.includes(:talk_type)
        .where(acceptance_status: 'accepted', speakers_confirmed: true)
        .order('title')
        .to_a
  end

  def self.all_accepted_tutorials
    Talk.includes(:talk_type)
        .where(acceptance_status: 'accepted')
        .where(talk_types: {eligible_for_free_ticket: true})
        .order('title')
        .to_a
  end

  def self.all_unassigned_tutorials
    includes(:slots).includes(:talk_type).where(acceptance_status: 'accepted',
                                                'slots.talk_id' => nil,
                                                'talk_types.eligible_for_free_ticket' => 't'
    )
  end

  def self.all_accepted_lightning_talks
    Talk.includes(:talk_type)
        .where(acceptance_status: 'accepted')
        .where(talk_types: {eligible_for_free_ticket: false})
        .order('title')
        .to_a
  end

  def self.all_with_speakers
    #with_exclusive_scope { find(:all, include: :users, order: 'users.last_name ') }
    talks = Talk.includes(:users, :talk_type)
    talks.order("users.last_name")
  end

  def self.count_accepted
    self.where(acceptance_status: 'accepted').count
  end

  def self.count_accepted_and_confirmed
    self.where(acceptance_status: 'accepted', speakers_confirmed: true).count
  end

  def self.could_not_attend
    self.where(acceptance_status: 'could_not_attend').count
  end

  def self.count_refused
    self.where(acceptance_status: 'refused').count
  end

  def self.count_pending
    self.where(acceptance_status: 'pending').count
  end

  def to_s
    "\"#{self.title}\" by #{self.speaker_name}"
  end

end
