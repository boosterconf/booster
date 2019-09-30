class AddTextToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :text, :string
  end
end
