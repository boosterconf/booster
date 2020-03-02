class TicketOrderingService
	def create_order_for_tickets(order_request_form)
		if(!order_request_form.valid?)
			return false
		end
		order = Order.new
		order.tickets = order_request_form.tickets

		fiken_client = Fiken.get_current
		if(order_request_form.new_order)

			if(order_request_form.new_customer)
				customer_details = order_request_form.customer_details
				customer_details.customer = true
				new_customer = fiken_client.create_contact(customer_details)
				customer = { url: new_customer.href }
			else
				customer = { url: order_request_form.fiken_customer_uri }
			end

			issueDate = (order.tickets.one?)? order.tickets.first.created_at.to_date : Date.today
			lines = order.tickets.map do |ticket|
				Fiken::CreateInvoiceLine.new(
						productUrl: ticket.ticket_type.fiken_product_uri,
						description: "#{ticket.ticket_type.name} for #{ticket.name}",
					)
			end
			invoice_request = Fiken::CreateInvoiceRequest.new(
				ourReference: "#{order.reference}",
				yourReference: order_request_form.their_reference,
				issueDate: issueDate,
				dueDate: Date.today + 14,
				lines: lines,
				customer: customer,
				bankAccountUrl: AppConfig.fiken_invoice_bank_account_href
				)

			invoice = fiken_client.create_invoice(invoice_request)
			if(!invoice)
				return false
			end
			fiken_sale_uri = invoice.sale_href
		else
			fiken_sale_uri = order_request_form.fiken_existing_sale_uri
		end
		order.fiken_sale_uri = fiken_sale_uri
		return order.save!
	end
end