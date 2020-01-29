module TicketOrder
class CompanyGroupInvoiceDetails
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :name, String

end
end