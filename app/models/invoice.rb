class Invoice < ActiveRecord::Base

  attr_accessible :adress, :city, :our_reference, :recipient_name, :your_reference, :zip, :country,
                  :email, :status

  has_many :registrations



end
