class Room < ActiveRecord::Base

  validates :name, presence: true
end
