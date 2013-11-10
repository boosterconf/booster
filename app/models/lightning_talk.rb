class LightningTalk < Talk

  def is_lightning_talk?
    true
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
