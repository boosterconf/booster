class InvoiceLine < ActiveRecord::Base

  belongs_to :invoice
  belongs_to :sponsor
  belongs_to :registration

end
