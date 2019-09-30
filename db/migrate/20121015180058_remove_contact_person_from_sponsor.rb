class RemoveContactPersonFromSponsor < ActiveRecord::Migration[4.2]
  def up
    remove_column :sponsors, :contact_person
  end

  def down
  end
end
