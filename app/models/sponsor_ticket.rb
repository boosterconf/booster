#
# The SponsorTicket object connects sponsors with their tickets.
# This is an explicit version of the has_and_belongs_to_many relationship
#
class SponsorTicket < ApplicationRecord
	belongs_to :sponsor
	belongs_to :ticket

	validates :sponsor, :ticket, presence: true

end
