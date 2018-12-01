class RemoveDinnerRegistrationFromRegistrationTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :registrations, :includes_dinner
    remove_column :registrations, :speakers_dinner
  end
end
