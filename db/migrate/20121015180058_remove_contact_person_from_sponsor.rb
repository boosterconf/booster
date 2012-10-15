class RemoveContactPersonFromSponsor < ActiveRecord::Migration
  def up
    remove_column :sponsors, :contact_person
  end

  def down
  end
end
