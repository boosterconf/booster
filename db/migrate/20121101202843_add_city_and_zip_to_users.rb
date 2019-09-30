class AddCityAndZipToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :city, :string
    add_column :users, :zip, :string
  end
end
