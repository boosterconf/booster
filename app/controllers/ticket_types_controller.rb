class TicketTypesController < ApplicationController
  respond_to :html, :js

  before_filter :require_admin

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
    @ticket_type = TicketType.new(params[:ticket_type])
    respond_to do |format|
      if @ticket_type.update_attributes(params[:ticket_type])
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
      if @ticket_type.update_attributes(params[:ticket_type])
        flash[:notice] = 'Ticket type updated.'
        format.html { redirect_to(ticket_types_url) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @ticket_type.errors, :status => :unprocessable_entity }
      end
    end
  end
end