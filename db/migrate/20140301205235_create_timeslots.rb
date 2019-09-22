class CreateTimeslots < ActiveRecord::Migration[4.2]
  def change
    create_table :timeslots do |t|
      t.string :location
      t.string :day
      t.string :time

      t.timestamps
    end
  end
end
