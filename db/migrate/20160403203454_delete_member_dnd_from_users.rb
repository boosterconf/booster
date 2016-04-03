class DeleteMemberDndFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :member_dnd
    remove_column :users, :role
  end
end
