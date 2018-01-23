class CachedTalks
  attr_accessor :workshops
  attr_accessor :lightning_talks
  attr_accessor :short_talks

  def initialize(workshops, lightning_talks, short_talks)
    @workshops = workshops
    @lightning_talks = lightning_talks
    @short_talks = short_talks
  end
end
