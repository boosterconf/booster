class Registration < ApplicationRecord

  acts_as_paranoid

  default_scope {order('registrations.created_at desc')}
  belongs_to :user

  before_destroy :destroy_talks_and_user

  def destroy_talks_and_user
    # This is necessary because the callback does not discriminate between
    # destroy and destroy! When we upgrade to Rails 4, this can be removed
    method = self.deleted_at ? :destroy! : :destroy

    if self.user != nil
      talks = self.user.talks
      talks.each do |talk|
        if talk.has_single_speaker?
          talk.send(method)
        end
      end

      self.user.send(method)
    end
  end

  def restore_talks_and_user
    self.user.restore
    self.user.talks.only_deleted.each do |talk|
      talk.restore
    end
  end

  def user
    User.unscoped {super}
  end
end
