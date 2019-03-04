module Fiken
	class BankAccount
		def initialize(api_object)
			@api_object = api_object
		end

		def name
			@api_object["name"]
		end

		def number
			@api_object["number"]
		end

		def bank_account_number
			@api_object["bankAccountNumber"]
		end

		def href
			@api_object["href"]
		end

		def descriptive_name
			"#{name} (#{bank_account_number})"
		end
	end
end