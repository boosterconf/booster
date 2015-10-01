class TalkType < ActiveRecord::Base
  has_many :talks

  def name_and_duration
    "#{name} (#{duration})"
  end

  def self.workshops
    where(is_workshop: true)
  end

  def self.talks
    where(is_workshop: false, eligible_for_cfp: true)
  end

end
