class Workshop < Talk

  validates :max_participants, presence: true,
            numericality: {only_integer: true, greater_than_or_equal: 20}

  after_initialize do |workshop|
    workshop.acceptance_status ||= 'pending'
    workshop.language = 'english' # all workshops are english
  end

  def is_lightning_talk?
    false
  end

  def is_tutorial?
    true
  end

  def self.all_accepted
    unscoped.all(include: [:talk_type],
                 conditions: ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 't'"],
                 order: 'title')
  end

end
