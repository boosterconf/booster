module Fiken
	class Invoice
		def initialize(api_object)
			@api_object = api_object
		end

		def sale_href
			@api_object["sale"]
		end
	end
end