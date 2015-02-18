class AddDeletedAtToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :deleted_at, :datetime
    add_index :registrations, :deleted_at
  end
end
