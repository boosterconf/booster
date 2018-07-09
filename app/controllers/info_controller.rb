class InfoController < ApplicationController
  def speakers
    @speakers = User.all_confirmed_speakers
  end

  def index
    @featured_speakers = User.featured_speakers.shuffle[0...6]
  end

  def about
    @organizers = User.featured_organizers.shuffle
  end

end
