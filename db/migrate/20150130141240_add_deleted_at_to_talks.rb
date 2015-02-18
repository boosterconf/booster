class AddDeletedAtToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :deleted_at, :datetime
    add_index :talks, :deleted_at
  end
end
