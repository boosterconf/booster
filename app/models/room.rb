class Room < ActiveRecord::Base
  attr_accessible :capacity, :name

  validates :name, presence: true
end
