class Ticket < ActiveRecord::Base

  attr_accessible :name, :email, :company, :feedback, :roles, :attend_dinner, :dietary_info

  belongs_to :ticket_type

  default_scope  { order('tickets.created_at desc') }

  def self.has_ticket(email)
    Ticket.exists?(:email => email)
  end
end
