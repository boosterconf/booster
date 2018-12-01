class RenameOptInToEmailAttribute < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :optInToEmailList, :opt_in_to_email_list
  end
end
