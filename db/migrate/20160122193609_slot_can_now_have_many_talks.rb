class SlotCanNowHaveManyTalks < ActiveRecord::Migration
  def up
    create_table :talk_positions do |t|
      t.integer :talk_id, null: false
      t.integer :slot_id, null: false
      t.integer :position, default: 1
    end

    Slot.all.each do |slot|
      TalkPosition.create(slot_id: slot.id, talk_id: slot.talk_id)
    end
  end

  def down
    drop_table :talk_position
  end
end
