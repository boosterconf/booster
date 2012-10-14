require 'test_helper'

class SponsorTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "sponsor states" do
    assert_equal "Suggested", Sponsor::STATES['suggested']
  end

  test "sponsor text" do
    foo = Sponsor.new
    foo.status = 'suggested'
    assert_equal "Suggested", foo.status_text
  end
end
