class DinnerController < ApplicationController

  respond_to :html

  before_action :require_admin

  def index
    @registrations = Registration.includes(:ticket_type).all
    respond_with @registrations
  end

  # todo fix attending listing
  def attend_conference_dinner
  end

  # todo fix attend speakers dinner listing
  def attend_speakers_dinner
  end
end
