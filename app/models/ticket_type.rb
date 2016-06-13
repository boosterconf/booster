class TicketType < ActiveRecord::Base

has_many :registrations


def self.current_normal_ticket
   find_by_name("organizer")
end


def self.lightning_speaker
  find_by_name("lightning_speaker")
end

end
