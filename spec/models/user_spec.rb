require 'rails_helper'

describe User, type: :model do
  it "does not say all talks refused if one talk is pending" do
    pending_talks_user = User.new
    pending_talks_user.talks << Talk.new({:acceptance_status => "pending"})
    expect(pending_talks_user.has_all_talks_refused?).to be_falsey
  end
end