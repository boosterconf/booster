class AddUniqueReferenceToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :unique_reference, :string
  end
end
