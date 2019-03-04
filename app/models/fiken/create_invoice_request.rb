module Fiken
    class CreateInvoiceRequest
        include Virtus.model
        include ActiveModel::Validations

        attribute :issueDate, Date
        attribute :dueDate, Date
        attribute :lines, Array[Fiken::CreateInvoiceLine]
        attribute :ourReference, String
        attribute :yourReference, String
        attribute :customer, Fiken::CreateInvoiceCustomer
        attribute :bankAccountUrl, String
        attribute :currency, String
        attribute :invoiceText, String
        attribute :cash, Axiom::Types::Boolean, default: false
        attribute :paymentAccount, String

        validates :issueDate, :dueDate, :lines, :customer, :bankAccountUrl, presence: true

        def as_json(options={})
            super(options).reject { |k, v| v.nil? }
        end
    end
end