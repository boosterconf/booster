module TicketOrder
class Attendee
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :name, String
  attribute :email, String
  attribute :company, String
  attribute :roles, Array[String]
  attribute :is_attending_conference_dinner, Boolean
  attribute :dietary_requirements, String

  validates :name, presence: true
  validates :email, presence: true
  validates :company, presence: true
  validate do
    errors.add :email, 'already has a ticket issued to it' if Ticket.where(email: email).any?
  end

  def persisted?
    false
  end
end
end