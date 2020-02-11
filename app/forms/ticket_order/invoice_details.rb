module TicketOrder
class InvoiceDetails
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :name, String
  attribute :email, String
  attribute :organizationIdentifier, String
  attribute :address, Fiken::Address
  attribute :invoice_reference, String

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def to_fiken_customer
  	Fiken::Contact.new({
  		customer: true,
  		name: name,
  		email: email,
  		address: address,
  		organizationIdentifier: organizationIdentifier
  	})
  end

end
end