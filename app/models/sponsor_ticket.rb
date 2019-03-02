#
# The SponsorTicket object connects sponsors with their tickets.
# This is an explicit version of a Ticket:belongs_to <-> Sponsor:has_many relationship
#
class SponsorTicket < ApplicationRecord
	belongs_to :sponsor
	belongs_to :ticket

	validates :sponsor, :ticket, presence: true

	scope :with_ticket_type, ->(ticket_type) { joins(:ticket).where(tickets: {ticket_type_id: ticket_type.id}) }

	def self.build_with_ticket_type(sponsor, ticket_type)
		sponsor_ticket = SponsorTicket.new
		sponsor_ticket.ticket = Ticket.build_prefilled_for_sponsor(sponsor, ticket_type)
		sponsor_ticket.sponsor = sponsor
		sponsor_ticket
	end
end
