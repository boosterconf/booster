class ProgramController < ApplicationController

  def index
    unless AppConfig.program_released || current_user.is_admin?
      return redirect_to root_path
    end

    @talks = {}
    @periods = {}

    if (params.has_key?(:cache) && params[:cache] == false)
      @talks = Talk.all.each {|talk| @talks[talk.id] = talk}
      @periods = Period.all.sort_by {|period| [period.day, period.start_time]}.reverse
    else
      @talks = Rails.cache.fetch(Cache::AllTalksCacheKey, expires_in: 30.minutes) do
         Talk.all.each {|talk| @talks[talk.id] = talk}
        @talks
      end
      @periods = Rails.cache.fetch(Cache::ProgramPeriodsCacheKey, expires_in: 30.minutes) do
        @periods = Period.all.sort_by {|period| [period.day, period.start_time]}.reverse
        @periods
      end
    end
  end
end
