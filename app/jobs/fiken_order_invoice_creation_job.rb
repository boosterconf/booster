class FikenOrderInvoiceCreationJob < ApplicationJob
	queue_as :default

	def perform(order_id, customerName, customerEmail, payment_reference = nil)
		ActiveRecord::Base.transaction do
			order = Order.find_by_id(order_id)
			customer = fiken_client
				.contacts
				.find_all { |customer| customer.email == customerEmail}
				.first
			if(customer == nil)
				customer = fiken_client.create_contact(Fiken::Contact.new(
					name: customerName,
					email: customerEmail,
					customer: true
					))
			end
			if(!customer)
				throw StandardError.new("Could not create invoice customer {name: #{customerName}, email: #{customerEmail}}")
			end

			if(order.payment_type == "card")
				payment_account = AppConfig.fiken_stripe_account_code
				cash = true
			else
				cash = false
				payment_account = nil
			end

			lines = order.tickets.map do |ticket|
				Fiken::CreateInvoiceLine.new(
					productUrl: ticket.ticket_type.fiken_product_uri,
					description: "#{ticket.ticket_type.name} for #{ticket.name}",
					)
			end
			invoice_request = Fiken::CreateInvoiceRequest.new(
				ourReference: "#{order.reference}",
				theirReference: "#{payment_reference}",
				issueDate: Date.today,
				dueDate: Date.today + 14,
				lines: lines,
				customer: { url: customer.href },
				cash: cash,
				paymentAccount: payment_account,
				bankAccountUrl: AppConfig.fiken_invoice_bank_account_href
				)
			fiken_invoice = fiken_client.create_invoice(invoice_request)
			order.fiken_sale_uri = fiken_invoice.sale_href
			order.save
		end
	end

	private

	def fiken_client
		@fiken_client ||= Fiken.get_current
	end
end
