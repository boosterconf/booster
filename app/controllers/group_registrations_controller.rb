class GroupRegistrationsController < ApplicationController

  def new
    @group_registration = GroupRegistrationForm.new
    @group_registration.tickets = [Ticket.new, Ticket.new, Ticket.new, Ticket.new]
  end

  def create
    @group_registration = GroupRegistrationForm.new(params[:group_registration_form])
    tickets = params[:group_registration_form][:tickets].reject {|e| e[:name].blank? }
                  .map { |ticket_params|
      Ticket.new(ticket_params)
    }
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
