class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :fiken_sale_uri
      t.string :stripe_charge_id

      t.timestamps
    end
    add_index :orders, :fiken_sale_uri
    add_index :orders, :stripe_charge_id
  end
end
