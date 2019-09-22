class CreateTickets < ActiveRecord::Migration[4.2]
  def change
    create_table :tickets do |t|
      t.string :name
      t.string :email
      t.string :company
      t.string :feedback
      t.boolean :attend_dinner
      t.string :dietary_info
      t.string :gender
      t.string :roles
      t.belongs_to :ticket_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
