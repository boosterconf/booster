class InvoiceLine < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :sponsor
  belongs_to :registration

  attr_accessible :price, :text, :sponsor, :sponsor_id, :registration
end
