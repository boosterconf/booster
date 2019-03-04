module Fiken
    class CreateInvoiceLine
        include Virtus.model
        include ActiveModel::Validations

        attribute :netAmount,   Integer
        attribute :vatAmount,   Integer
        attribute :grossAmount, Integer
        attribute :vatType, String
        attribute :vatPercent,  Integer
        attribute :unitNetAmount,   Integer
        attribute :discountPercent, Integer
        attribute :quantity,    Integer
        attribute :description, String
        attribute :comment, String
        attribute :productUrl,  String
        attribute :incomeAccount,   String

        validates :netAmount, :vatAmount, :grossAmount,
                :vatType, :vatPercent, :unitNetAmount,
                :description, :incomeAccount,
                presence: true,
                unless:  Proc.new { |invoice_line| invoice_line.productUrl.present? }

        def as_json(options={})
            super(options).reject { |k, v| v.nil? }
        end
    end
end