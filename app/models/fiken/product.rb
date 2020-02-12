module Fiken
	class Product
		def initialize(data, api = nil)
			@data = data
			@api = api
		end

		def name
			@data["name"]
		end

		def href
			if(api)
				api._links["self"].to_s
			end
		end

		private

		attr_reader :api
	end
end