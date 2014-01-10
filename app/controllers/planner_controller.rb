class PlannerController < ApplicationController

  before_filter :require_admin

  def index
    @days = ["Wednesday 12th", "Thursday 13th",  "Friday 14th"]
    @num_tracks = 7
  end

end