class ProgramController < ApplicationController

  def index

    unless AppConfig.program_released
      return redirect_to root_path
    end

    all_talks = Talk.all
    @talks = {}
    all_talks.each { |talk| @talks[talk.id] = talk }
    puts "abc"
    puts @talks
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def workshops
    @day = params[:day]
    ids = params[:filter].split(',').map(&:to_i)
    @talks = Talk.find(ids)
  end

  def lightning
    all_talks = Talk.all
    @talks = {}
    all_talks.each { |talk| @talks[talk.id] = talk }
    puts @talks
    respond_to do |format|
      format.html 
    end
  end
end