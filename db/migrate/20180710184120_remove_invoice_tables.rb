class RemoveInvoiceTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :invoices
    drop_table :invoice_lines
  end
end
