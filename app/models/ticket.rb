require 'csv'

class Ticket < ApplicationRecord

  def self.from_attendee_form(form)
    self.new({
      name: form.name,
      email: form.email,
      company: form.company,
      roles: form.roles,
      attend_dinner: form.is_attending_conference_dinner,
      dietary_info: form.dietary_requirements
    })
  end

  belongs_to :ticket_type
  has_one :sponsor_ticket, dependent: :destroy
  belongs_to :order

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
