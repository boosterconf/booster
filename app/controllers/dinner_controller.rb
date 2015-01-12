class DinnerController < ApplicationController

  respond_to :html

  before_filter :require_admin

  def index
    @registrations = Registration.order(:ticket_type_old).all
    respond_with @registrations
  end

  def attend_conference_dinner
    registration = User.find(params[:user_id]).registration

    registration.includes_dinner = params[:attend]
    registration.save

    render :json => {
        :id => registration.user.id,
        :attend => registration.includes_dinner
    }
  end

  def attend_speakers_dinner
    registration = User.find(params[:user_id]).registration

    registration.speakers_dinner = params[:attend]
    registration.save

    render :json => {
        :id => registration.user.id,
        :attend => registration.speakers_dinner
    }
  end

end
