#
# The SponsorTicket object connects sponsors with their tickets.
# This is an explicit version of a Ticket:belongs_to <-> Sponsor:has_many relationship
#
class SponsorTicket < ApplicationRecord
	belongs_to :sponsor
	belongs_to :ticket

	validates :sponsor, :ticket, presence: true

	scope :with_ticket_type, ->(ticket_type) { joins(:ticket).where(tickets: {ticket_type_id: ticket_type.id}) }
end
