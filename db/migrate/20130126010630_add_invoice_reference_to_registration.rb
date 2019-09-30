class AddInvoiceReferenceToRegistration < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :invoice_id, :integer
  end
end
