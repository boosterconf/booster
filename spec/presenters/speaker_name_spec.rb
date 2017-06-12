require 'rails_helper'

describe SpeakerName, type: :presenter do
  describe "#speaker_name" do
    it "shows one name when only one speaker" do
      speaker = User.new({:first_name => "Bob The Cat", :last_name => "Lastname"})

      speaker_name_presenter = SpeakerName.new([speaker])

      expect(speaker_name_presenter.to_s).to eq(speaker.full_name)

    end

    it "shows two names joined by ' and ' when two speakers" do
      speaker1 = User.new({:first_name => "Bob", :last_name => "Lastname"})
      speaker2 = User.new({:first_name => "Jenna", :last_name => "Hill"})

      speaker_name_presenter = SpeakerName.new([speaker1, speaker2])

      expect(speaker_name_presenter.to_s).to include(speaker1.full_name)
      expect(speaker_name_presenter.to_s).to include(" and ")
      expect(speaker_name_presenter.to_s).to include(speaker2.full_name)

    end

    it "shows named and unnamed speaker one speaker is not named" do
      speaker1 = User.new({:first_name => "Bob", :last_name => "Lastname"})
      speaker2 = User.new

      speaker_name_presenter = SpeakerName.new([speaker1, speaker2])

      expect(speaker_name_presenter.to_s).to include(speaker1.full_name)
      expect(speaker_name_presenter.to_s).to include(" and ")
      expect(speaker_name_presenter.to_s).to include("unnamed")

    end
  end
end