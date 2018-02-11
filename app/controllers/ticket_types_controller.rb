class TicketTypesController < ApplicationController
  respond_to :html, :js

  before_action :require_admin

  def index
    @ticket_types = TicketType.all
  end

  def new
    @ticket_type = TicketType.new
  end

  def edit
    @ticket_type = TicketType.find(params[:id])
  end

  def create
    @ticket_type = TicketType.new(ticket_type_params)
    respond_to do |format|
      if @ticket_type.update_attributes(ticket_type_params)
        flash[:notice] = 'Ticket type created.'
        format.html { redirect_to(ticket_types_url) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @ticket_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @ticket_type = TicketType.find(params[:id])
    respond_to do |format|
      if @ticket_type.update_attributes(ticket_type_params)
        flash[:notice] = 'Ticket type updated.'
        format.html { redirect_to(ticket_types_url) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @ticket_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  def ticket_type_params
    params.require(:ticket_type).permit(:name, :reference, :price, :dinner_included)
  end
end