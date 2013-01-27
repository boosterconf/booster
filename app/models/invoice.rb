class Invoice < ActiveRecord::Base

  attr_accessible :adress, :city, :our_reference, :recipient_name, :your_reference, :zip, :country,
                  :email, :status

  has_many :registrations

  validates :email, :format => { :with => Authlogic::Regex.email }

  def total
    registrations.map(&:price).inject(0) { |sum, price| sum + price }
  end

  def delivery_method
    self.email.present? ? "email" : "snail mail"
  end

  def is_possible_to_change?
    status == "not_invoiced"
  end

end
