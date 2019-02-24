class SponsorTicket < ApplicationRecord
	belongs_to :sponsor
	belongs_to :ticket

	validates :sponsor, :ticket, presence: true

	def self.create_tickets_for_accepted_sponsors

	end
end
