class Slot < ActiveRecord::Base

  attr_accessible :period_id, :talk_id, :room_id

  belongs_to :talk
  belongs_to :period
  belongs_to :room

  validates :period, presence: true
  validates :room, presence: true
  validates :talk, presence: true
  validates_uniqueness_of :room_id, scope: :period_id
  validate :talk_and_period_has_same_type

  def to_s
    "\"#{talk.title}\" at #{period}"
  end

  private
  def talk_and_period_has_same_type
    case period.period_type
    when "workshop"
      errors.add(:talk, "You tried to add a #{talk.talk_type.name.downcase} to a #{period.period_type.humanize} period") unless talk.is_workshop?
    when "short_talk"
      errors.add(:talk, "You tried to add a #{talk.talk_type.name.downcase} to a #{period.period_type.humanize} period") unless talk.is_short_talk?
    end
  end

end