class AddEmailToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :email, :string
    add_column :invoices, :country, :string
  end
end
