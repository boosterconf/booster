require 'csv'

class Ticket < ApplicationRecord

  belongs_to :ticket_type
  has_one :sponsor_ticket, dependent: :destroy

  default_scope  { order('tickets.created_at desc') }

  def self.has_ticket(email)
    Ticket.exists?(:email => email)
  end

  def self.to_csv
    attributes = %w{email name company ticket_type price vat}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |ticket|
        csv << [ticket.email, ticket.name, ticket.company, ticket.ticket_type.name, ticket.ticket_type.price, ticket.ticket_type.vat]
      end
    end
  end

  def self.count_by_ticket_type(ticket_type)
    Ticket.where(ticket_type_id: ticket_type.id).count
  end

  def self.all_unordered
    Ticket.where(order_id: nil)
  end

  def self.build_prefilled_for_sponsor(sponsor, ticket_type)
    ticket = Ticket.new
    ticket.ticket_type = ticket_type
    ticket.attend_dinner = true
    ticket.name = "Please fill in name of attendee"
    ticket.company = sponsor.name
    ticket.email = sponsor.email
    ticket.reference = SecureRandom.urlsafe_base64
    return ticket
  end
end
