class TalkType < ApplicationRecord
  has_many :talks

  def name_and_duration
    "#{name} (#{duration})"
  end

  def is_keynote?
    name == "Keynote"
  end
  
  def is_lightning_talk?
    name == "Lightning talk"
  end
  
  def is_short_talk?
    name == "Short talk"
  end

  def self.workshops
    where(is_workshop: true)
  end

  def self.talks
    where(is_workshop: false, eligible_for_cfp: true)
  end

end
