class AddCityAndZipToUsers < ActiveRecord::Migration
  def change
    add_column :users, :city, :string
    add_column :users, :zip, :string
  end
end
