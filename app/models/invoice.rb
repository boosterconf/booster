class Invoice < ActiveRecord::Base

  attr_accessible :adress, :city, :our_reference, :recipient_name, :your_reference, :zip, :country,
                  :email, :status, :delivery_method

  has_many :registrations

  validates :email, :format => { :with => Authlogic::Regex.email }, :allow_blank => true

  validate :delivery_method_present?

  after_initialize do |invoice|
    invoice.status = 'Registered'
  end

  def total
    registrations.map(&:price).inject(0) { |sum, price| sum + price }
  end

  def delivery_method
    self.email.present? ? "email" : "snail_mail"
  end

  def delivery_method=(method)
    # Hack
  end

  def is_possible_to_change?
    status == "not_invoiced"
  end

  private

  def delivery_method_present?
    if !(email.blank? ^ adress.blank?)
      errors.add(:delivery_method, "Delivery method for invoice must be present")
    end
  end
end
