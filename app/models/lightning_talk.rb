class LightningTalk < Talk

  after_initialize do |workshop|
    workshop.acceptance_status ||= 'pending'
  end
  # This is a hack to get path helpers working. See
  # http://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails
  def self.model_name
    Talk.model_name
  end

  def is_lightning_talk?
    true
  end

  def is_workshop?
    false
  end

  def is_short_talk?
    false
  end

  def self.all_accepted
    unscoped.all(include: [:talk_type],
                 conditions: ["acceptance_status = 'accepted'"],
                 order: 'title')
  end

end
