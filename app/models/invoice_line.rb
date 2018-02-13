class InvoiceLine < ApplicationRecord
  belongs_to :invoice
  belongs_to :sponsor
  belongs_to :registration

end
