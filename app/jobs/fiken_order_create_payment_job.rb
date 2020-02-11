class FikenOrderCreatePaymentJob < ApplicationJob
    def perform(order_id, payment_intent_id)
        order = Order.find_by_id!(order_id)
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

        fiken_sale = fiken_client.sale(order.fiken_sale_uri)

        payment = Fiken::Payment.new({account: AppConfig.fiken_stripe_account_code,
            amount: payment_intent.amount_received,
            date: Time.at(payment_intent.created).to_datetime
        })
        fiken_sale.create_payment(payment)
    end
    private

    def fiken_client
        @fiken_client ||= Fiken.get_current
    end

end