class Period < ActiveRecord::Base

  attr_accessible :day, :start_time, :end_time

  has_many :slots

  validates_uniqueness_of :start_time, :scope => [:end_time, :day]

  def to_s
    day.strftime("%a") + " " + start_time.strftime("%H:%M") + "-" + end_time.strftime("%H:%M")
  end

  def day_of_the_week
    strftime('%a')
  end

  def talk_in(room)
    slot = slots.find { |slot| slot.room == room }
    return nil unless slot
    slot.talk
  end

end