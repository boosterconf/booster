class DropTimeSlotsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :timeslots
  end
end
