class EventsController < ApplicationController

  respond_to :html, :js

  def create

    @event = Event.new(event_params)
    @event.user = current_user
    @event.sponsor = Sponsor.find(params[:sponsor_id])
    @event.save

    respond_with @event, :location => edit_sponsor_url(@event.sponsor.id)
  end

  private
  def event_params
    params.require(:event).permit(:comment, :sponsor_id, :user_id)
  end

end