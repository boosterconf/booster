class Keynote < Talk

  after_initialize do |talk|
    talk.acceptance_status ||= 'accepted'
  end

  def is_lightning_talk?
    false
  end

  def is_tutorial?
    false
  end

  def self.all_accepted
    unscoped.all(include: [:talk_type],
                 conditions: ["acceptance_status = 'accepted'"],
                 order: 'title')
  end

end
