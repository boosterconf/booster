class AddFikenProductUriToTicketTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :ticket_types, :fiken_product_uri, :string
    add_index :ticket_types, :fiken_product_uri
  end
end
