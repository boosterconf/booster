class MakeSponsorTicketsTicketIdUnique < ActiveRecord::Migration[5.2]
  def up
  	add_index :sponsor_tickets, :ticket_id, unique: true
  	Sponsor.all_accepted.each do |sponsor|
  		Ticket.where(email: sponsor.email).each do |ticket|
  			sponsor_ticket = SponsorTicket.new
  			sponsor_ticket.sponsor = sponsor
  			sponsor_ticket.ticket = ticket
  			sponsor_ticket.save!
  		end
  	end
  end
  def down
  	remove_index :sponsor_tickets, :ticket_id
  end
end
