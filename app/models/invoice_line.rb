class InvoiceLine < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :invoice
  belongs_to :sponsor
  belongs_to :registration

end
