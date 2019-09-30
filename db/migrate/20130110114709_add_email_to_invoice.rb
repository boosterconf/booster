class AddEmailToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :email, :string
    add_column :invoices, :country, :string
  end
end
