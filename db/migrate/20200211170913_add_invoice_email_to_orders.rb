class AddInvoiceEmailToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :invoice_email, :string
  end
end
