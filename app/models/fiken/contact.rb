module Fiken
	class Contact
		include Virtus.model
        include ActiveModel::Validations

		def initialize(api_object)
			@api_object = api_object
			super(api_object)
		end

		attribute :name,					String
		attribute :email,					String
		attribute :organizationIdentifier,	String
		attribute :address,					Fiken::Address
		attribute :phoneNumber,				String
		attribute :customerNumber,			Integer
		alias customer_number customerNumber
		attribute :customer,				Boolean
		attribute :supplierNumber,			Integer
		attribute :supplier,				Boolean
		attribute :currency,				String
		attribute :memberNumber,			Integer
		attribute :language,				String

		validates :name, :email, presence: true

		def href
			@api_object["href"]
		end

        def as_json(options={})
            super(options).reject { |k, v| v.nil? }
        end
	end
end