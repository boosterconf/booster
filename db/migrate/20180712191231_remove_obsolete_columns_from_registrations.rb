class RemoveObsoleteColumnsFromRegistrations < ActiveRecord::Migration[5.2]
  def change
    remove_column :registrations, :price
    remove_column :registrations, :invoiced_at
    remove_column :registrations, :paid_at
    remove_column :registrations, :is_earlybird
    remove_column :registrations, :ticket_type_old
    remove_column :registrations, :payment_notification_params
    remove_column :registrations, :payment_complete_at
    remove_column :registrations, :paid_amount
    remove_column :registrations, :payment_reference
    remove_column :registrations, :manual_payment
    remove_column :registrations, :invoice_address
    remove_column :registrations, :invoice_description
    remove_column :registrations, :free_ticket
    remove_column :registrations, :invoiced
    remove_index :registrations, :invoice_id
    remove_column :registrations, :invoice_id
    remove_index :registrations, :ticket_type_id
    remove_column :registrations, :ticket_type_id

  end
end
