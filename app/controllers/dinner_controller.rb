class DinnerController < ApplicationController

  respond_to :html

  before_action :require_admin

  def index
    @tickets = Ticket.includes(:ticket_type).all
    @totalAttendingConferenceDinner = @tickets.count {|t| t.attend_dinner}
    @totalAttendingSpeakersDinner = @tickets.count {|t| t.attend_speakers_dinner}
    respond_with @tickets
  end
end
