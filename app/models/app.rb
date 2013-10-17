class App < ActiveRecord::Base
  def self.early_bird_end_date
    AppConfig.early_bird_ends
  end

  def self.speakers_close_date
    Time.zone.parse("2014-01-28 23:59:59")
  end
end