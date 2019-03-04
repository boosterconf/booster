module Fiken
	class Contact

		#def initialize(api_object)
		#	@api_object = api_object
		#end

		#def name
		#	@api_object["name"]
		#end

		#def href
		#	@api_object["href"]
		#end

		#def customer_number
		#	@api_object["customerNumber"]
		#end

		attribute :name,					String
		attribute :email,					String
		attribute :organizationIdentifier,	String
		attribute :address,					Address
		attribute :phoneNumber,				String
		attribute :customerNumber,			Integer
		attribute :customer,				Boolean
		attribute :supplierNumber,			Integer
		attribute :supplier,				Boolean
		attribute :currency,				String
		attribute :memberNumber,			Integer
		attribute :language,				String
	end
end