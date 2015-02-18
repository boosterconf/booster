class AddDeletedAtToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :deleted_at, :datetime
    add_index :speakers, :deleted_at
  end
end
