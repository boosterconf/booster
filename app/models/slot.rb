class Slot < ActiveRecord::Base

  attr_accessible :period_id, :room_id

  has_many :talk_positions
  has_many :talks, through: :talk_positions
  belongs_to :period
  belongs_to :room

  validates :period, presence: true
  validates :room, presence: true
  validate :talk_and_period_has_same_type


  def talk
    raise "Can't get talk on multi-talk slots" if talks.count > 1
    talks.first
  end

  def to_s
    "\"#{talk.title}\" at #{period}"
  end

  private
  def talk_and_period_has_same_type
    talk = Talk.find(talk_positions.first.talk_id)
    case period.period_type
    when "workshop"
      errors.add(:talk, "You tried to add a #{talk.talk_type.name.downcase} to a #{period.period_type.humanize} period") unless talk.is_workshop?
    when "short_talk"
      errors.add(:talk, "You tried to add a #{talk.talk_type.name.downcase} to a #{period.period_type.humanize} period") unless talk.is_short_talk?
    end
  end

end