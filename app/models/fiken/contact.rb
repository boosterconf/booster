module Fiken
	class Contact
		include Virtus.model
        include ActiveModel::Validations

		def initialize(data = {}, api = nil)
			@api = api
			super(data)
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
			if(api)
				api._links["self"].to_s
			end
		end


        def as_json(options={})
            super(options).reject { |k, v| v.nil? }
        end


        private
        attr_reader :api
	end
end