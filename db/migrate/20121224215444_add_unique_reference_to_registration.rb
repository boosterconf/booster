class AddUniqueReferenceToRegistration < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :unique_reference, :string
  end
end
