class Invoice < ActiveRecord::Base

  attr_accessible :adress, :city, :our_reference, :recipient_name, :your_reference, :zip, :country,
                  :email, :status, :delivery_method, :created_at, :invoiced_at

  has_many :registrations

  validates :email, :format => { :with => Authlogic::Regex.email }, :allow_blank => true


  after_initialize do |invoice|
    invoice.status ||= 'Registered'
  end

  def total
    registrations.map(&:price).inject(0) { |sum, price| sum + price }
  end

  def delivery_method
    self.email.present? ? 'email' : 'snail_mail'
  end

  def delivery_method=(method)
    # Hack
  end

  def possible_to_change?
    status == 'not_invoiced'
  end

  def unpaid?
    status == 'invoiced'
  end

  def registrations
    Registration.where(invoice_id: id)
  end

end
