class CreateInvoiceLines < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_lines do |t|
      t.string :text
      t.integer :price
      t.references :sponsor
      t.references :registration
      t.references :invoice

      t.timestamps
    end
    add_index :invoice_lines, :invoice_id
    add_index :invoice_lines, :registration_id
    add_index :invoice_lines, :sponsor_id
  end
end
