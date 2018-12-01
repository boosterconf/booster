require 'rails_helper'

describe TalkType, type: :model do
  describe "is_keynote?" do
    it "is false when name is Lightning talk" do
      talk_type = TalkType.new
      talk_type.name = 'Lightning talk'
      expect(talk_type.is_keynote?).to be false
    end
    it "is false when name is Short talk" do
      talk_type = TalkType.new
      talk_type.name = 'Short talk'
      expect(talk_type.is_keynote?).to be false
    end
    it "is true when name is Keynote" do
      talk_type = TalkType.new
      talk_type.name = 'Keynote'
      expect(talk_type.is_keynote?).to be true
    end
  end
end
