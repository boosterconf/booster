class RemoveInvoicedAndPaidOnSponsor < ActiveRecord::Migration
  def up
    remove_column :sponsors, :paid
    remove_column :sponsors, :invoiced
  end

  def down
    add_column :sponsors, :paid, :date
    add_column :sponsors, :invoiced, :date
  end
end
