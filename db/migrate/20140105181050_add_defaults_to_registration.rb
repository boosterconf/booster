class AddDefaultsToRegistration < ActiveRecord::Migration
  def up
    change_column_default(:registrations, :free_ticket, false)
    change_column_default(:registrations, :invoiced, false)
  end

  def down
  end
end
