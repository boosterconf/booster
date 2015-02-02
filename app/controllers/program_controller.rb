class ProgramController < ApplicationController

  def index
    unless AppConfig.program_released || current_user.is_admin
      return redirect_to root_path
    end

    all_talks = Talk.all
    @talks = {}
    all_talks.each { |talk| @talks[talk.id] = talk }

    @periods = Period.all.sort_by { |period| [period.day, period.start_time] }.reverse
  end
end