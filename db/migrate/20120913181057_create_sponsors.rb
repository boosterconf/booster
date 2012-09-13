class CreateSponsors < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
      t.string :name
      t.string :email
      t.integer :user_id
      t.date :invoiced
      t.date :paid
      t.string :comment
      t.string :contact_person
      t.string :status
      t.string :contact_person_phone
      t.string :location
      t.boolean :was_sponsor_last_year
      t.datetime :last_contacted_at

      t.timestamps
    end
  end
end
