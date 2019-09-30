class AddDefaults2ToRegistration < ActiveRecord::Migration[4.2]
  def change
  	change_column_default(:registrations, :registration_complete, false)
  end
end
