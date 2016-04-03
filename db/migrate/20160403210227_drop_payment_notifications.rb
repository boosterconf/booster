class DropPaymentNotifications < ActiveRecord::Migration
  def change
    drop_table :payment_notifications
  end
end
