class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :talks, [:id, :type]
    add_index :talks, :talk_type_id
    add_index :tags_talks, [:tag_id, :talk_id]
    add_index :registrations, :user_id
    add_index :registrations, :invoice_id
    add_index :timeslots, :talk_id
    add_index :events, :user_id
    add_index :events, :sponsor_id
    add_index :reviews, :reviewer_id
    add_index :reviews, :talk_id
    add_index :sponsors, :user_id
    add_index :slots, :talk_id
    add_index :slots, :period_id
    add_index :slots, :room_id
    add_index :speakers, :talk_id
    add_index :speakers, :user_id
    add_index :speakers, [:talk_id, :user_id]
    add_index :payment_notifications, :registration_id
    add_index :comments, :user_id
    add_index :comments, :talk_id
    add_index :bios, :user_id
  end
end
