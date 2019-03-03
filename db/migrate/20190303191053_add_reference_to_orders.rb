class AddReferenceToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :reference, :string
    add_index :orders, :reference
  end
end
