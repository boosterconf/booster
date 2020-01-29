module TicketOrder
class InvoiceDetails
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :name, String
  attribute :email, String
  attribute :address, String

  validates :name, presence: true
  validates :email, presence: true

end
end