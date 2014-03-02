class Timeslot < ActiveRecord::Base
  attr_accessible :day, :location, :time, :talk_id
end
