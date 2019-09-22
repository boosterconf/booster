class AddReferenceToTicket < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :reference, :string
  end
end
