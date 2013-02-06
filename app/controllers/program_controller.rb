class ProgramController < ApplicationController
  before_filter :require_admin, :except => [:index]

  # GET /users
  # GET /users.json
  def index

    all_talks = Talk.all
    @talks = {}
    all_talks.each { |talk| @talks[talk.id] = talk }

    respond_to do |format|
      format.html # index.html.erb
      #format.json { render json: @users }
    end
  end
end