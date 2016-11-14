class Invoice < ActiveRecord::Base

  attr_accessible :adress, :city, :our_reference, :recipient_name, :your_reference, :zip, :country,
                  :email, :status, :delivery_method, :text, :created_at, :invoiced_at

  validates :email, format: { with: Authlogic::Regex.email }, allow_blank: true
  validates :status, inclusion: { in: %w(not_invoiced invoiced paid) }
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

  def pay!
    self.paid_at = DateTime.now
    self.status = 'paid'
  end

  def invoice!
    self.invoiced_at = DateTime.now
    self.status = 'invoiced'
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

  def self.create_sponsor_invoice_for(sponsor)

    return if sponsor.invoice_line

    invoice = create!(
        email: sponsor.email,
        our_reference: sponsor.user.try(:full_name),
        your_reference: sponsor.contact_person_full_name
    )

    invoice.invoice_lines.create!(
        sponsor_id: sponsor.id,
        text: "Partnership package for Booster #{AppConfig.year}",
        price: AppConfig.partner_price_in_nok_before_vat
    )
  end

  def self.create_stripe_payment(ticket, charge)
    invoice = create!(
        {
            email: ticket.email,
            recipient_name: ticket.name,
            our_reference: charge.id,
            your_reference: "kontakt@boosterconf.no",
            status: "paid",
            paid_at: DateTime.now
        })

    invoice.invoice_lines.create!(
        text: "#{ticket.ticket_type.name } for Booster #{AppConfig.year} - Stripe Payment",
        price: ticket.ticket_type.price
    )
  end

  def self.create_ticket_invoice(ticket, payment_info, payment_zip)
    invoice = create!(
        {
            email: ticket.email,
            recipient_name: ticket.name,
            our_reference: ticket.email,
            your_reference: "kontakt@boosterconf.no",
            text: payment_info,
            zip: payment_zip
        })
    invoice.invoice_lines.create!(
        text: "#{ticket.ticket_type.name } for Booster #{AppConfig.year} - Invoice",
        price:  ticket.ticket_type.price
    )
  end

end
