class AddDefaultsToRegistration < ActiveRecord::Migration[4.2]
  def up
    change_column_default(:registrations, :free_ticket, false)
    change_column_default(:registrations, :invoiced, false)
  end

  def down
  end
end
