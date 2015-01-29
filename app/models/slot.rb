class Slot < ActiveRecord::Base

  attr_accessible :period_id, :talk_id, :room_id

  belongs_to :talk
  belongs_to :period
  belongs_to :room

  validates_uniqueness_of :room_id, scope: :period_id

  def to_s
    "\"#{talk.title}\" at #{period}"
  end

end