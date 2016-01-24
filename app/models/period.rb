class Period < ActiveRecord::Base

  attr_accessible :day, :start_time, :end_time, :period_type

  has_many :slots, order: 'room_id'

  validates_uniqueness_of :start_time, scope: [:end_time, :day]

  TYPES = %w(workshop lightning keynote break short_talk)

  def to_s
    day_of_the_week + ' ' + start_and_end_time
  end

  def start_and_end_time
    start_time.strftime('%H:%M') + '-' + end_time.strftime('%H:%M')
  end

  def day_of_the_week
    start_time.strftime('%a')
  end

  def talk_in(room, position=1)
    slot = slot_in(room)
    return nil unless slot

    slot.talk_positions.find { |t| t.position == position }.try(:talk)
  end

  def slot_in(room)
    slots.find { |slot| slot.room == room }
  end

end