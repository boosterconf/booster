require 'rails_helper'

describe User, type: :model do

  describe  "#has_all_talks_refused?" do
    it "is true if user has only refused talks" do
      user_with_refused_talk = User.new
      user_with_refused_talk.talks << Talk.new({:acceptance_status => "refused"})

      expect(user_with_refused_talk.has_all_talks_refused?).to be_truthy
    end

    it "is not true when there are talks with a different status than refused" do
      user = User.new
      user.talks << Talk.new({:acceptance_status => "pending"})
      user.talks << Talk.new({:acceptance_status => "cheese is not a status"})
      user.talks << Talk.new({:acceptance_status => "refused"})

      expect(user.has_all_talks_refused?).to be_falsey
    end
  end

end