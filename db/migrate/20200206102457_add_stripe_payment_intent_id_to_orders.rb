class AddStripePaymentIntentIdToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :payment_intent_id, :string
  end
end
