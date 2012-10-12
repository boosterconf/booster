class EventsController < ApplicationController

  respond_to :html, :js

  def create

    @event = Event.new(params[:event])
    @event.user = current_user
    @event.sponsor = Sponsor.find(params[:sponsor_id])
    @event.save

    respond_with @event, :location => edit_sponsor_url(@event.sponsor.id)
  end

end