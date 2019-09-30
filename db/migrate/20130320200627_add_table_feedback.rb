class AddTableFeedback < ActiveRecord::Migration[4.2]
  def up
    drop_table :feedbacks if ActiveRecord::Base.connection.table_exists? 'feedbacks'

    create_table :feedbacks do |t|
      t.string :comment

      t.timestamps
    end
  end
end
