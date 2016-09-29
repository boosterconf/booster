class TicketType < ActiveRecord::Base

  has_many :registrations
  attr_accessible :name, :reference, :price

  def self.current_normal_ticket
     find_by_reference("organizer")
  end

  def self.lightning_speaker
    find_by_reference("lightning_speaker")
  end

end
