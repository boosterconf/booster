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
    if status_was_changed_to_accepted && @sponsor.not_invoiced?
      Invoice.create_sponsor_invoice_for(@sponsor)
    end

    true
  end

  def status_was_changed_to_accepted
    @sponsor.status != @old_status && @sponsor.status == 'accepted'
  end
end
