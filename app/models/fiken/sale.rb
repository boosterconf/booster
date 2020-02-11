module Fiken
	class Sale

		include Virtus.model
        include ActiveModel::Validations

		def initialize(data = {}, api = nil)
			@api = api
			super(data)
		end

		attribute :identifier,				String
		attribute :customer,				String
		attribute :kind,					String

		def href
			api._links["self"].to_s
		end

		# This is ugly but I see no other way to get it
		def ui_url
			href
				.gsub("api/v1/companies", "foretak")
				.gsub("sales", "handel/salg")
		end
		def create_payment(payment_object)
			api._links["https://fiken.no/api/v1/rel/payments"]._post(payment_object.to_hash)
		end


		private
		attr_reader :api

	end
end