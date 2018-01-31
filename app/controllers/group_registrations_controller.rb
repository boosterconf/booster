class GroupRegistrationsController < ApplicationController

  def new
    @group_registration = GroupRegistrationForm.new
    @group_registration.tickets = [Ticket.new, Ticket.new, Ticket.new, Ticket.new]
  end

  def create
    @group_registration = GroupRegistrationForm.new(params[:group_registration_form])
    tickets = params[:group_registration_form][:tickets].reject {|e| e[:name].blank?}
                  .map {|ticket_params|
                    Ticket.new(ticket_params)
                  }

    ticket_type = TicketType.current_normal_ticket
    if current_user && current_user.is_admin
      ticket_type = TicketType.find_by_id(params[:group_registration_form][:ticket_type_id])
    end
    tickets.each {|ticket| ticket.ticket_type = ticket_type}

    @group_registration.tickets = tickets
    if @group_registration.save
      render action: 'confirmation'
    else
      render action: 'new'
    end

  rescue => e
    puts e
    flash[:error] = e.message
    @group_registration.tickets = tickets
    render action: 'new'
  end
end
