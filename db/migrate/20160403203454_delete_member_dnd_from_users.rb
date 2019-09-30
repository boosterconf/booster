class DeleteMemberDndFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :member_dnd
    remove_column :users, :role
  end
end
