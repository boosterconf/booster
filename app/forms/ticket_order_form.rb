class TicketOrderForm
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def self.payment_method_types
    payment_types = {}
    if(AppConfig.stripe_on)
  	  payment_types["card"] = "Card"
    end
    payment_types["invoice"] = "Invoice me"
    payment_types["company_group_invoice"] = "Add me to a group invoice"
    return payment_types
  end

  attribute :attendees, Array[TicketOrder::Attendee], required: true
  attribute :ticket_type_reference, String, default: "card"
  attribute :how_did_you_hear_about_us, String
  attribute :payment_details_type, String, default: "card"
  attribute :card_payment_details, TicketOrder::CardPaymentDetails
  attribute :invoice_details, TicketOrder::InvoiceDetails
  attribute :company_invoice_details, TicketOrder::CompanyGroupInvoiceDetails

  validates :attendees, presence: true
  validate do
    if(payment_details_type == "card" && attendees.count > 1)
      errors.add :attendees, 'Multiple attendees cannot be paid by card'
    end
    if attendees.any? {|r| !r.valid? }
      errors.add(:attendees, :invalid, :value => attendees)
    end

    if(payment_details_type == "invoice" || payment_details_type == "card")
      if(!invoice_details.valid?)
        errors.add(:invoice_details, :invalid, :value => invoice_details)
      end
    end

    if(payment_details_type == "company_group_invoice")
      if(!company_invoice_details.valid?)
        errors.add(:company_invoice_details, :invalid, :value => company_invoice_details)
      end
    end

  end

  def persisted?
    false
  end

  def attendees_attributes=(attributes)
    self.attendees = attributes.values.map do |values|
      TicketOrder::Attendee.new(values)
    end
  end
end
