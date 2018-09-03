class AddOptInToEmailListToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :optInToEmailList, :boolean, default: false
  end
end
