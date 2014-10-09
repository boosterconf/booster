class Talk < ActiveRecord::Base
  default_scope :order => 'talks.created_at desc'

  attr_accessible :talk_type, :talk_type_id, :language, :title, :description, :audience_level, :max_participants,
                  :participant_requirements, :equipment, :room_setup, :accepted_guidelines, :acceptance_status,
                  :slide, :outline, :appropriate_for_roles

  has_many :speakers
  has_many :users, :through => :speakers
  has_many :comments, :order => 'created_at', :include => :user
  has_and_belongs_to_many :tags
  belongs_to :talk_type
  has_many :reviews, order: 'created_at desc', include: :reviewer
  has_attached_file :slide, PAPERCLIP_CONFIG
  has_many :timeslots

  validates_attachment_content_type :slide,
                                    :content_type => ['application/pdf', 'application/vnd.ms-powerpoint', 'application/ms-powerpoint', %r{application/vnd.openxmlformats-officedocument}, %r{application/vnd.oasis.opendocument}, 'application/zip', 'application/x-7z-compressed', 'application/x-gtar']

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
    users.sort{|x,y| x.full_name && y.full_name ? x.full_name <=> y.full_name : x.full_name ? -1 : 1}
          .map{|u| u.full_name ? u.full_name : 'another speaker'}.join(" and ")
  end

  def speaker_name_or_email
    users.sort{|x,y| x.full_name && y.full_name ? x.full_name <=> y.full_name : x.full_name ? -1 : 1}
        .map{|u| u.full_name ? u.full_name : u.email ? "(#{u.email})" : 'another speaker'}.join(" and ")
  end

  def speaker_invited
    users.any?(&:invited)
  end

  def is_presented_by?(speaker)
    users.include?(speaker)
  end

  def starts_now?(day_time)
    if timeslots.length > 0
      day_time.start_with?(timeslot.day) && day_time.end_with?(timeslot.time)
    else
      true
    end
  end

  def timeslot 
    timeslots.sort! {|a,b| a.time <=> b.time} 
    timeslots[0]
  end

  def speaker_emails
    users.map(&:email).join(", ")
  end

  def option_text
    %Q[#{id} - "#{trunc(title, 30)}" (#{trunc(speaker_name, 20)})]
  end

  def trunc(text, length)
    (text.length < length + 3) ? text : "#{text.first(length)}..."
  end

  def describe_audience_level
    case audience_level
      when 'novice' then
        'Novice'
      when 'intermediate' then
        'Intermediate'
      when 'expert' then
        'Expert'
      else
        ''
    end
  end

  def license
    "by"
  end

  def email_is_sent?
    email_sent
  end

  def accept!
    self.acceptance_status = "accepted"
    self
  end

  def accepted?
    self.acceptance_status == "accepted"
  end

  def pending?
    self.acceptance_status == "pending"
  end

  def refused?
    self.acceptance_status == "refused"
  end

  def refuse!
    self.acceptance_status = "refused"
    self
  end

  def regret!
    self.acceptance_status = "pending"
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

  def average_feedback_score
    score = self.sum_of_votes.to_f / self.num_of_votes.to_f
    "%.2f" % score
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
    reviews.map { |r| r.reviewer }.include?(user)
  end

  def self.all_pending_and_approved
    all(order: 'acceptance_status, id desc', include: :reviews).select {
        |t| !t.refused? && !t.users.first.nil? && t.year == AppConfig.year
    }
  end

  def self.all_pending_and_approved_tag(tag)
    talks_tmp = all(:order => 'acceptance_status, id desc').select {
        |t| !t.users.first.nil? && !t.refused?
    }
    talks = []
    talks_tmp.each do |talk|
      if talk.tags.include? tag
        talks.push talk
      end
    end
    talks
  end

  def self.all_accepted
    all(:include => :slots, :conditions => "acceptance_status = 'accepted'")
  end

  def self.all_accepted_tutorials
    unscoped.all(:include => [:talk_type], :conditions => ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 't'"], :order => "title")
  end

  def self.all_accepted_lightning_talks
    all(:include => :talk_type, :conditions => ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 'f'"], :order => "title ")
  end

  def self.all_with_speakers
    with_exclusive_scope { find(:all, :include => :users, :order => "users.name ") }
  end

  def self.add_feedback(talk_id, sum, num)
    talk = Talk.find(talk_id, :include => :users)
    talk.sum_of_votes = sum
    talk.num_of_votes = num

    talk.save
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

  def self.find_all_with_ids(id_array)
    self.find_all(:conditions => {:id => id_array})
  end

end
