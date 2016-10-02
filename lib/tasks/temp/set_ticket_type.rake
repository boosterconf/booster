# lib/tasks/temporary/users.rake
namespace :registrations do
  desc "Update ticket type on users to new ticket type record"
  task set_ticket_type: :environment do
    tickets = Registration.all
    puts "Going to update #{tickets.count} users"

    ActiveRecord::Base.transaction do
      tickets.each do |ticket|
        ticket.ticket_type = TicketType.find_by_reference(ticket.ticket_type_old)
        ticket.save
        print "."
      end
    end

    puts " All done now!"
  end
end