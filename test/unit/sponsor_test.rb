require 'test_helper'

class SponsorTest < ActiveSupport::TestCase
  test "sponsor states" do
    assert_equal "Suggested", Sponsor::STATES['suggested']
  end

  test "sponsor text" do
    foo = Sponsor.new
    foo.status = 'suggested'
    assert_equal "Suggested (missing email)", foo.status_text
  end
end
