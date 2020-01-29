class DirectPaymentsController < ApplicationController
	def new
		order = Order.find_by_id(params[:order_id])
		line_items = order.tickets.map do |ticket|
			{
				name: ticket.ticket_type.name.slice(0, ([ticket.ticket_type.name.length, 22].min)), # whut
				description: ticket.ticket_type.name,
				amount: (ticket.ticket_type.price_with_vat * 100).to_int,
				currency: 'nok',
				quantity: 1,
			}
		end
		@session = Stripe::Checkout::Session.create(
		  customer_email: (order.tickets.count == 1)? order.tickets.first.email : nil,
          payment_method_types: ['card'],
          client_reference_id: order.reference,
          line_items: line_items,
          success_url: completed_order_direct_payment_url(order) + "?session_id={CHECKOUT_SESSION_ID}",
          cancel_url: "https://boosterconf.no",
        )
	end

	def completed
		session = Stripe::Checkout::Session.retrieve(params[:session_id])
		order = Order.find_by_reference!(session.client_reference_id)
		if(!order.stripe_charge_id.present?)
			render "error"
		else
			redirect_to order_path(order)
		end
	end

	def webhook
		payload = request.raw_post
		event = nil

		  sig_header = request.headers["Stripe-Signature"]
		  begin
		    event = Stripe::Webhook.construct_event(
		      payload, sig_header, Rails.configuration.stripe[:endpoint_secret]
		    )
		  rescue JSON::ParserError => e
		    # Invalid payload
		    head 400
		    return
		  rescue Stripe::SignatureVerificationError => e
		    # Invalid signature
		    head 400
		    return
		  end

		  case(event["type"])
		  when "checkout.session.completed"
		  	session = event["data"]["object"]

		    payment_intent = Stripe::PaymentIntent.retrieve(session["payment_intent"])
		    charge = payment_intent["charges"]["data"].first

			order = Order.find_by_reference!(session["client_reference_id"])
		    order.stripe_charge_id = charge["id"]
		    order.save

		    if(order.tickets.count == 1)
		    	ticket = order.tickets.first
		    	FikenOrderInvoiceCreationJob.perform_later(order.id, ticket.name, ticket.email)
		    	BoosterMailer.ticket_confirmation_paid(ticket).deliver_later
		    else
		    	# We don't support direct payment of group orders yet, this should not happen
		    end
		  end
		  #status 200
		  head :ok
	end
end