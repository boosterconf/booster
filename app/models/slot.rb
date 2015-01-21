class Slot < ActiveRecord::Base

  attr_accessible :period_id, :talk_id

  belongs_to :talk
  belongs_to :period

  attr_accessible :room

  validates_uniqueness_of :room, scope: :period_id

  def to_s
    "\"#{talk.title}\" at #{period}"
  end

end