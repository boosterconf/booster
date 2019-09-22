class AddVolunteers < ActiveRecord::Migration[4.2]
  def change
    create_table :volunteers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
    end
  end
end
