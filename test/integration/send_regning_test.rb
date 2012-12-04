require "test/unit"
require "test_helper"
#require "app/controllers/send_regning"

class SendRegningTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail

    # To change this template use File | Settings | File Templates.
    #fail("Not implemented")
  end

  def test_send_regning
    response = SendRegning.invoice_person("some_client_id_invoice1", "Test Deltaker", "kjersti.berg@gmail.com",
                                        "5015", "Bergen", "Early bird", "1")
    assert response
  end
end