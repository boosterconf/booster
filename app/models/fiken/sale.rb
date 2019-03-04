module Fiken
	class Sale
		def initialize(api_object)
			@api_object = api_object
		end

		def identifier
			@api_object["identifier"]
		end

		def href
			@api_object["href"]
		end

		def customer
			@api_object["customer"]
		end

		# This is ugly but I see no other way to get it
		def ui_url
			href
				.gsub("api/v1/companies", "foretak")
				.gsub("sales", "handel/salg")
		end

	end
end