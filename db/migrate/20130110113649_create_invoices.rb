class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :our_reference
      t.string :your_reference
      t.string :recipient_name
      t.string :adress
      t.string :zip
      t.string :city

      t.timestamps
    end
  end
end
