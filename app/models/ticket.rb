class Ticket < ActiveRecord::Base

  attr_accessible :name, :email, :company, :feedback, :roles, :attend_dinner, :dietary_info, :reference

  belongs_to :ticket_type

  default_scope  { order('tickets.created_at desc') }

  def self.has_ticket(email)
    Ticket.exists?(:email => email)
  end

  def self.to_csv
    attributes = %w{email name company}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |ticket|
        csv << attributes.map{ |attr| ticket.send(attr) }
      end
    end
  end

end
