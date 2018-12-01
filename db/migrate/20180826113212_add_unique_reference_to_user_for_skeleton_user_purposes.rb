class AddUniqueReferenceToUserForSkeletonUserPurposes < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unique_reference, :string
  end
end
