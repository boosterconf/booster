class CreateSponsorTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :sponsor_tickets do |t|
      t.integer :ticket_id
      t.integer :sponsor_id

      t.foreign_key :tickets
      t.foreign_key :sponsors

      t.timestamps
    end
  end
end
