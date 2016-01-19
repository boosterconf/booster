class Workshop < Talk

  validates :max_participants, presence: true,
            numericality: { only_integer: true, greater_than_or_equal: 20 }

  validates :appropriate_for_roles, presence: true

  after_initialize do |workshop|
    workshop.acceptance_status ||= 'pending'
    workshop.language = 'english' # all workshops are english
  end

  # This is a hack to get path helpers working. See
  # http://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails
  def self.model_name
    Talk.model_name
  end

  def is_lightning_talk?
    false
  end

  def is_workshop?
    true
  end
  def is_short_talk?
    false
  end

  def self.all_accepted
    unscoped.all(include: [:talk_type],
                 conditions: ["acceptance_status = 'accepted' AND talk_types.eligible_for_free_ticket = 't'"],
                 order: 'title')
  end

end
