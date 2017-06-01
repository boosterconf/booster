require 'rails_helper'

describe User, type: :model do
  it "does not say all talks refused if one talk is pending" do
    user_with_pending_talk = User.new
    user_with_pending_talk.talks << Talk.new({:acceptance_status => "pending"})
    expect(user_with_pending_talk.has_all_talks_refused?).to be_falsey
  end
end