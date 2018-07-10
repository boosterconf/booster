class Registration < ApplicationRecord

  acts_as_paranoid

  default_scope {order('registrations.created_at desc')}
  belongs_to :user
  belongs_to :invoice
  has_one :invoice_line

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

  def self.find_by_params(params)
    puts params
    if params[:conditions]
      return where(params[:conditions])
    elsif params[:filter]
      case params[:filter]
        when 'completed'
          return where({:registration_complete => true})
        when 'not_completed'
          return where({:registration_complete => false})
        when 'er_fakturert'
          return where(
              {
                  :free_ticket => false,
                  :registration_complete => false,
                  :manual_payment => true,
                  :invoiced => true
              })
        when 'skal_foelges_opp'
          return where(
              {
                  :free_ticket => false,
                  :registration_complete => false,
                  :manual_payment => false
              })
        when 'skal_faktureres'
          return where(
              {
                  :free_ticket => false,
                  :registration_complete => false,
                  :manual_payment => true,
                  :invoiced => false
              })
        else
          return []
      end
    else
      all
    end
  end

  def user
    User.unscoped {super}
  end
end
