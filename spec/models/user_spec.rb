require 'rails_helper'

RSpec.describe User, type: :model do

  #def test_user_with_one_pending_talk_does_not_have_all_talks_refused
  #  god = users(:god)
  #  assert !god.has_all_talks_refused?
  #end

  it "does not have all talks refused if one talk is pending" do
    pending_talks_user = User.new
    talk = Talk.new
    talk.acceptance_status = 'pending'
    pending_talks_user.talks << talk
    expect(pending_talks_user.has_all_talks_refused?).to be_falsey
  end
end