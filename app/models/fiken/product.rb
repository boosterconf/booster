module Fiken
	class Product
		def initialize(api_object)
			@api_object = api_object
		end

		def name
			@api_object["name"]
		end

		def href
			@api_object["href"]
		end
	end
end