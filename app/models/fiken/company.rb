module Fiken
	class Company
		def initialize(data_object, client)
			@data_object = data_object
			@client = client
		end

		def sales
			client["https://fiken.no/api/v1/rel/sales"]._get._embedded["https://fiken.no/api/v1/rel/sales"].map { |sale| Fiken::Sale.new(sale.to_hash, sale) }
		end

		def contacts
			client["https://fiken.no/api/v1/rel/contacts"]._get._embedded["https://fiken.no/api/v1/rel/contacts"].map { |contact| Fiken::Contact.new(contact.to_hash, contact) }
		end

		def bank_accounts
			client["https://fiken.no/api/v1/rel/bank-accounts"]._get._embedded["https://fiken.no/api/v1/rel/bank-accounts"].map { |bank_account| Fiken::BankAccount.new(bank_account.to_hash) }
		end

		def products
			client["https://fiken.no/api/v1/rel/products"]._get._embedded["https://fiken.no/api/v1/rel/products"].map { |product| Fiken::Product.new(product.to_hash, product) }
		end

		def sale(url)
			sale = get(url)
			Fiken::Sale.new(sale.to_hash, sale)
		end

		def create_invoice(invoice_request)
			if(!invoice_request.valid?)
				return false
			end
			response = client._links["https://fiken.no/api/v1/rel/create-invoice-service"]._post(invoice_request.as_json.to_json)
			# url = @api_object.create_invoice(invoice_request.as_json)
			Fiken::Invoice.new(get(response._response.headers[:location]).to_hash)
		end

		def create_contact(contact_details)
			if(!contact_details.valid?)
				return false
			end
			response = client._links["https://fiken.no/api/v1/rel/contacts"]._post(contact_details.as_json.to_json)
			c = get(response._response.headers[:location])
			Fiken::Contact.new(c.to_hash, c)

			#url = @api_object.contact(contact_details.as_json)
			#api_result = @api_object.get_contact(url)
			#api_result["href"] = url
			#Fiken::Contact.new(api_result)
		end

		# private

		attr_reader :client

		def get(href)

			api = Hyperclient.new(href) do |client|
			  client.basic_auth(Rails.application.secrets.fiken[:username], Rails.application.secrets.fiken[:password])
			end
			api._get
		end
	end
end