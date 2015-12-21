class Invoice < ActiveRecord::Base

  attr_accessible :adress, :city, :our_reference, :recipient_name, :your_reference, :zip, :country,
                  :email, :status, :delivery_method, :text, :created_at, :invoiced_at

  validates :email, format: { with: Authlogic::Regex.email }, allow_blank: true
  validates :status, inclusion: { in: %w(not_invoiced invoiced) }
  has_many :invoice_lines

  def delivery_method
    self.email.present? ? 'email' : 'snail_mail'
  end

  def possible_to_change?
    status == 'not_invoiced'
  end

  def unpaid?
    status == 'invoiced'
  end

  def add_user(user)
    invoice_lines.create!(
        text: "#{user.registration.ticket_description} for #{user.email}",
        price: user.registration.ticket_price,
        registration: user.registration
    )
  end

  def total
    invoice_lines.map(&:price).sum
  end

end
