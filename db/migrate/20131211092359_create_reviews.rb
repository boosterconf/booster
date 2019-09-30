class CreateReviews < ActiveRecord::Migration[4.2]
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
