module Fiken
	class Company
		def initialize(api_object)
			@api_object = api_object
		end

		def sales
			@api_object.sales.map { |sale_hash| Fiken::Sale.new(sale_hash) }
		end

		def contacts
			@api_object.contacts.map { |contact_hash| Fiken::Contact.new(contact_hash) }
		end

		def bank_accounts
			@api_object.bank_accounts.map { |account_hash| Fiken::BankAccount.new(account_hash) }
		end

		def products
			@api_object.products.map { |product_hash| Fiken::Product.new(product_hash) }
		end

		def create_invoice(invoice_request)
			if(!invoice_request.valid?)
				return false
			end
			url = @api_object.create_invoice(invoice_request.as_json)
			Fiken::Invoice.new(@api_object.get_invoice(url))
		end

		def create_contact(contact_details)
			if(!contact_details.valid?)
				return false
			end

			url = @api_object.contact(contact_details)
			Fiken::Contact.new(@api_object.get_contact(url))
		end
	end
end