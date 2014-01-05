class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :talk
      t.belongs_to :reviewer # User
      t.string :subject
      t.string :text

      t.timestamps
    end
  end
end
