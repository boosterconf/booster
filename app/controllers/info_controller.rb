# Controller for displaying static html pages
# See http://railscasts.com/episodes/117-semi-static-pages for details
class InfoController < ApplicationController

  # Page cache for all views.
  # See http://www.railsenvy.com/2007/2/28/rails-caching-tutorial for details
  #caches_page :index, :arrangoerene, :lyntaler, :openspace

#  def applyCacheControl
#    response.headers['Cache-Control'] = 'public, max-age=3600'
#  end

  def speakers
    @speakers = User.all_accepted_speakers
  end

  def index
    @featured_speakers = User.featured_speakers.shuffle[0...4]
    @feedback = Feedback.new
  end

  def about
    @organizers = User.featured_organizers.shuffle
  end

end
