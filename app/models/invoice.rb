class Invoice < ActiveRecord::Base

  attr_accessible :adress, :city, :our_reference, :recipient_name, :your_reference, :zip, :country,
                  :email, :status

  has_many :registrations

  def total
    registrations.map(&:price).inject(0) { |sum, price| sum + price }
  end
end
