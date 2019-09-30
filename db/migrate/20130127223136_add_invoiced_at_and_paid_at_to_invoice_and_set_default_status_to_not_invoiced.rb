class AddInvoicedAtAndPaidAtToInvoiceAndSetDefaultStatusToNotInvoiced < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :invoiced_at, :timestamp
    add_column :invoices, :paid_at, :timestamp

    change_column :invoices, :status, :string, :default => "not_invoiced"

    Invoice.all.each { |invoice|
      if invoice.status == nil
        invoice.status = "not_invoiced"
        invoice.save!
      end
    }
  end
end
