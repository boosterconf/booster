class PlannerController < ApplicationController

  before_filter :require_admin

  def index
    @num_tracks = 3
    @talks_per_track = 4
    @talks = LightningTalk.all_with_speaker
  end

end