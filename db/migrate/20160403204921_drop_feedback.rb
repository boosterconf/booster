class DropFeedback < ActiveRecord::Migration
  def change
    drop_table :feedback_votes
    drop_table :feedback_comments
    drop_table :talk_feedbacks
    drop_table :feedbacks
  end
end
