class CreateTimeslots < ActiveRecord::Migration
  def change
    create_table :timeslots do |t|
      t.string :location
      t.string :day
      t.string :time

      t.timestamps
    end
  end
end
