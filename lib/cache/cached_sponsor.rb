class CachedSponsor
  attr_accessor :name
  attr_accessor :website
  attr_accessor :logoUrl

  def initialize (name, website, logoUrl)
    @name = name
    @website = website
    @logoUrl = logoUrl
  end
end
