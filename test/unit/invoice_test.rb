require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase

  # Scenarios:
  # Register a new user individually, send individual invoice
  # Register a set of users, send one invoice for all
  # Does it make sense to have an invoice and no registrations? Not really.

  def test_new_invoice
    invoice = Invoice.new
    assert invoice.status == "Registered"
  end

end
