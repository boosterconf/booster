class AddTalkIdToTimeslot < ActiveRecord::Migration
  def change
    add_column :timeslots, :talk_id, :integer
  end
end
