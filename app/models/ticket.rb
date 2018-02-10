require 'csv'

class Ticket < ActiveRecord::Base

  belongs_to :ticket_type

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
end
