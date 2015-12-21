class SponsorInvoiceCreator < SimpleDelegator

  def initialize(sponsor)
    @old_status = sponsor.status
    @sponsor = sponsor
    super
  end

  def save
    @sponsor.save && create_sponsor_invoice
  end

  private
  def create_sponsor_invoice
    if status_was_changed_to_accepted && !@sponsor.invoiced
      invoice = Invoice.create!(
          email: @sponsor.email,
          our_reference: @sponsor.user.full_name,
          your_reference: @sponsor.contact_person_full_name
      )

      invoice.invoice_lines.create!(
          sponsor: @sponsor,
          text: "Partnership package for Booster #{AppConfig.year}",
          price: AppConfig.sponsor_price_in_nok_before_vat
      )
    end

    true
  end

  def status_was_changed_to_accepted
    @sponsor.status != @old_status && @sponsor.status == 'accepted'
  end
end
