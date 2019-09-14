class GroupRegistrationForm
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :delivery_method
  attribute :email
  attribute :adress
  attribute :zip
  attribute :your_reference
  attribute :text
  attribute :company
  attribute :ticket_type_id

  attribute :tickets, Array[Ticket]

  attribute :total

  validates :delivery_method, presence: true
  validates :zip, presence: true
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true

  validates :email, presence: true, if: lambda { |gr| gr.delivery_method == 'email' }
  validates :adress, presence: true, if: lambda { |gr| gr.delivery_method == 'snail_mail' }

  def valid_emails
    tickets.each do |ticket|
      errors.add(:tickets, "#{ticket.email} is not a valid email") unless ticket.email.match(Devise.email_regexp)
    end
  end

  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def persist!
    tickets.each { |ticket|
      ticket.company = company
      ticket.attend_dinner = ticket.ticket_type.dinner_included
      ticket.reference = SecureRandom.urlsafe_base64
      ticket.save
      BoosterMailer.ticket_assignment(ticket).deliver_now
    }
    payment_info = { :payment_info => your_reference,
                     :payment_zip => zip,
                     :payment_email => delivery_method == 'email' ? email : adress,
                     :extra_info => text }
    if tickets.first && tickets.first.ticket_type.paying_ticket?
      BoosterMailer.invoice_to_fiken(tickets, nil, payment_info).deliver_now
    end
  end
end