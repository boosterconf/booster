class App < ActiveRecord::Base
  def self.early_bird_end_date
    Time.zone.parse("2013-01-12 23:59:59")
  end

  def self.speakers_close_date
    Time.zone.parse("2013-01-01 23:59:59")
  end
end