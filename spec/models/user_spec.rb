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

  describe "#attending_dinner" do
    def create_valid_user
      return User.new({
                        :phone_number => "1234",
                        :first_name => "firstname",
                        :last_name => "lastname",
                        :company => "companyname",
                        :email => "email@example.com",
                        :password => "pass123",
                        :password_confirmation => "pass123"
                    })
    end


    it "is attending participants dinner" do
      attending_user = create_valid_user
      attending_user.attending_dinner!

      expect(attending_user.attending_dinner?).to be_truthy
    end

    it "is not attending participants dinner" do
      non_attending_user = create_valid_user
      non_attending_user.not_attending_dinner!

      expect(non_attending_user.attending_dinner?).to be_falsey
    end

    it "is not attending dinner participants when not explicitly set" do
      attendance_not_set_user = create_valid_user

      expect(attendance_not_set_user.attending_dinner?).to be_falsey
    end

  end
end