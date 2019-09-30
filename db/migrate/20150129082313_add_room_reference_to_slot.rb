class AddRoomReferenceToSlot < ActiveRecord::Migration[4.2]

  def change
    change_table :slots do |t|
      t.remove :room
      t.references :room, index: true
    end
  end

end
