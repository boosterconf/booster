class ProgramController < ApplicationController
  def index
    unless AppConfig.program_released || current_user.is_admin?
      return redirect_to root_path
    end

    @talks = {}
    @periods = {}

    if (params.has_key?(:cache) && params[:cache] == false)
      @talks = fetch_talks.each {|talk| @talks[talk.id] = talk}
      @periods = fetch_periods
    else
      @talks = Rails.cache.fetch(Cache::AllTalksCacheKey, expires_in: 30.minutes) do
         fetch_talks.each {|talk| @talks[talk.id] = talk}
        @talks
      end
      @periods = Rails.cache.fetch(Cache::ProgramPeriodsCacheKey, expires_in: 30.minutes) do
        fetch_periods
      end
    end

    @opening_keynote = @talks[1364]
    @closing_keynote = @talks[1368]

    respond_to do |format|
      format.html
      format.pdf do
        pdf_data = Rails.cache.fetch(Cache::ProgramPeriodsCacheKey + ".pdf", expires_in: 30.minutes) do
          pdf = ProgramPdf.new(@opening_keynote, @periods, @talks, @closing_keynote)
          pdf.render
        end
        send_data pdf_data, filename: "booster_program_#{AppConfig.year}.pdf",
                                type: 'application/pdf',
                                disposition: 'inline'
      end
    end
  end

  private
  def fetch_talks
    Talk.includes(:speakers => :user).all
  end

  def fetch_periods
    Period.includes(:slots => [:room, :talks, :talk_positions => {:talk => {:speakers => :user }} ]).all.sort_by {|period| [period.day, period.start_time]}.reverse
  end
end
