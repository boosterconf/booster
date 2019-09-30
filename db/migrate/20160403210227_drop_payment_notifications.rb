class DropPaymentNotifications < ActiveRecord::Migration[4.2]
  def change
    drop_table :payment_notifications
  end
end
