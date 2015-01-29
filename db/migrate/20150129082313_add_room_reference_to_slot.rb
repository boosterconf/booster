class AddRoomReferenceToSlot < ActiveRecord::Migration

  def change
    change_table :slots do |t|
      t.remove :room
      t.references :room, index: true
    end
  end

end
