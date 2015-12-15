class AddTextToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :text, :string
  end
end
