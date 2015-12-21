class InvoiceLine < ActiveRecord::Base
  belongs_to :invoices
  belongs_to :sponsor
  belongs_to :registration

  attr_accessible :price, :text, :sponsor, :registration
end
