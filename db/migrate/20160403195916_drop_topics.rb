class DropTopics < ActiveRecord::Migration[4.2]
  def change
    drop_table :topics
  end
end
