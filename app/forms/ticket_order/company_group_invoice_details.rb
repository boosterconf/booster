module TicketOrder
class CompanyGroupInvoiceDetails
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :name, String
  attribute :email, String
  attribute :organizationIdentifier, String

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :organizationIdentifier, presence: true

  validate :organizationIdentifier do
    if(organizationIdentifier.gsub(/[^\d]/, "").length != 9)
      errors.add :organizationIdentifier, 'should be exactly 9 digits'
    end
  end

end
end