class GroupRegistrationsController < ApplicationController
  before_action :ticket_sales_open?, only: [:new, :create]

  def new
    @group_registration = GroupRegistrationForm.new
    @group_registration.tickets = [Ticket.new, Ticket.new, Ticket.new, Ticket.new]
  end

  def create
    filtered_params = group_registration_params
    @group_registration = GroupRegistrationForm.new(group_registration_params)
    # TODO This stuff needs to go into the Form object - the whole point of it is to isolate logic like this
    # to a separate class. Get rid of #to_unsafe_h at that time.
    tickets = filtered_params.to_unsafe_h[:tickets].reject {|e| e[:name].blank?}
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
  end

  private
  def group_registration_params
    params.require(:group_registration_form).permit(:ticket_type_id, :delivery_method, :email, :adress, :zip,
                                                    :your_reference, :text, :company, tickets: [:name, :email])
  end

  def ticket_sales_open?
    if current_user && current_user.is_admin
      true
    else
      if AppConfig.ticket_sales_open
        return true
      end
      flash[:notice] = "Follow @boosterconf on Twitter to be notified when the next batch of tickets is available."
      redirect_to root_path
    end
  end

end
