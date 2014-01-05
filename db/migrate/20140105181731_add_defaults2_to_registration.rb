class AddDefaults2ToRegistration < ActiveRecord::Migration
  def change
  	change_column_default(:registrations, :registration_complete, false)
  end
end
