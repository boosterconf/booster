# TODO: Delete, it is no longer in use
class PaymentNotification < ActiveRecord::Base
  belongs_to :registration
  serialize :params
  after_create :mark_registration_as_paid
  #validates_presence_of :transaction_id
  #validates_numericality_of :paid_amount
  
  private
  
  def mark_registration_as_paid
    if status == "Completed"
     # cart.update_attribute(:purchased_at, Time.now)
    end
  end
end
