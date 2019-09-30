class AddDeletedAtToRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :deleted_at, :datetime
    add_index :registrations, :deleted_at
  end
end
