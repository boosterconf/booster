require 'rails_helper'

describe User, type: :model do
  def create_valid_user
    return User.new({
                        :phone_number => "1234",
                        :first_name => "firstname",
                        :last_name => "lastname",
                        :company => "companyname",
                        :email => "email@example.com",
                        :password => "password12345",
                        :password_confirmation => "password12345"
                    })
  end

  def create_speaker
    user = create_valid_user
    user
  end

  describe "#has_all_talks_refused?" do
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

  describe "#has_valid_email?" do
    it "accepts a valid email address" do
      user = User.new({:email => "valid.email@example.com"})
      expect(user.has_valid_email?).to be_truthy
    end

    it "does not accept an invalid email address" do
      user = User.new({:email => "not a valid email"})
      expect(user.has_valid_email?).to be_falsey
    end

  end

  describe "#valid?" do
    it "is valid if it contains all the necessary things" do
      user = create_valid_user
      expect(user.valid?).to be_truthy
    end

    it "is not valid if things are missing" do
      user = User.new
      expect(user.valid?).to be_falsey
    end
  end
end
