class ProgramController < ApplicationController

  def index

    unless AppConfig.program_released
      return redirect_to root_path
    end

    all_talks = Talk.all
    @talks = {}
    all_talks.each { |talk| @talks[talk.id] = talk }

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end