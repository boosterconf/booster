module TicketOrder
class CardPaymentDetails
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

end
end