module Fiken
	class Address
		include Virtus.model

		attribute :address1
		attribute :address2
		attribute :postalCode
		attribute :postalPlace
		attribute :country
	end
end