class PlannerController < ApplicationController

  before_filter :require_admin

  def index
    @num_tracks = 3
    @talks_per_slot = 4
    @num_slots = 2
    @talks = LightningTalk.all_with_speaker
  end

  def update

  end

end