module Fiken
	class Contact
		def initialize(api_object)
			@api_object = api_object
		end

		def name
			@api_object["name"]
		end

		def href
			@api_object["href"]
		end

		def customer_number
			@api_object["customerNumber"]
		end
	end
end