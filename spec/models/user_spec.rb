require 'rails_helper'

describe User, type: :model do
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

  def create_speaker
    user = create_valid_user
    user.registration.created_at = Time.now
    user.registration.ticket_type = TicketType.new({:reference => "speaker"})
    user
  end

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

  describe "#update_to_paying_user" do
    #denne metoden er bare i bruk internt i User. Burde ikke testene i stedet være for update_ticket_type!
    # som er den eneste metoden som bruker denne?

    it "speaker registrations gets set to early bird price when updated to paying user before early bird ends" do
      early_registration_speaker = create_speaker
      AppConfig.early_bird_ends = Time.now + 1.day

      early_registration_speaker.update_to_paying_user

      expect(early_registration_speaker.registration.ticket_type.reference).to eq("early_bird")
    end

    it "speaker registrations gets set to full price when when updated to paying user after early bird has ended" do
      late_registration_speaker = create_speaker
      AppConfig.early_bird_ends = Time.now - 1.day

      late_registration_speaker.update_to_paying_user

      expect(late_registration_speaker.registration.ticket_type.reference).to eq("full_price")
    end
  end

  describe "#update_ticket_type!" do
    it "updating ticket for user with pending workshop sets ticket type to speaker" do
      speaker = create_speaker
      speaker.talks << Talk.new({:acceptance_status => "pending", :talk_type => TalkType.new({:name => "Workshop"})})

      speaker.update_ticket_type!
      expect(speaker.registration.ticket_type.reference).to eq('speaker')
    end

    it "updating ticket for user with pending lightning talk sets ticket type to lightning" do
      speaker = create_speaker
      speaker.talks << Talk.new({:acceptance_status => "pending", :talk_type => TalkType.new({:name => "Lightning talk"})})

      speaker.update_ticket_type!
      expect(speaker.registration.ticket_type.reference).to eq('lightning')
    end

    it "updating ticket for user with pending short talk sets ticket type to lightning" do
      speaker = create_speaker
      speaker.talks << Talk.new({:acceptance_status => "pending", :talk_type => TalkType.new({:name => "Short talk"})})

      speaker.update_ticket_type!
      expect(speaker.registration.ticket_type.reference).to eq('lightning')
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