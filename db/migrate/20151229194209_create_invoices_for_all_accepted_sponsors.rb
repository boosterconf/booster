class CreateInvoicesForAllAcceptedSponsors < ActiveRecord::Migration
  def up
    Sponsor.all_accepted.each do |sponsor|
      Invoice.create_sponsor_invoice_for(sponsor)
    end
  end

  def down
  end
end
