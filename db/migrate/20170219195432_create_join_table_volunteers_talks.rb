class CreateJoinTableVolunteersTalks < ActiveRecord::Migration[4.2]
  def change
    create_join_table :volunteers, :talks do |t|
      t.index [:volunteer_id, :talk_id]
      t.index [:talk_id, :volunteer_id]
    end
  end
end
