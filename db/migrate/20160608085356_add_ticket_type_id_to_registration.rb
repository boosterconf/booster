class AddTicketTypeIdToRegistration < ActiveRecord::Migration[4.2]
  def change
    add_reference :registrations, :ticket_type, index: true, foreign_key: true, default: 2
  end
end
