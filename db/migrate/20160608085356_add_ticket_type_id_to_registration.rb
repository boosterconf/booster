class AddTicketTypeIdToRegistration < ActiveRecord::Migration
  def change
    add_reference :registrations, :ticket_type, index: true, foreign_key: true, default: 2
  end
end
