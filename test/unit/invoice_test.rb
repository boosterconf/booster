require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase

  def test_new_invoice
    invoice = Invoice.new
    invoice.status = "Invoiced"
    assert invoice.status == "Invoiced"
  end

end
