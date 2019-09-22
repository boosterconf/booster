class AddTalkIdToTimeslot < ActiveRecord::Migration[4.2]
  def change
    add_column :timeslots, :talk_id, :integer
  end
end
