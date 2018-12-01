require 'rails_helper'

describe TalkType, type: :model do
  def create_sut(name)
    talk_type = TalkType.new
    talk_type.name = name
    talk_type
  end
  describe "is_keynote?" do
    it "is false when name is Lightning talk" do
      expect(create_sut('Lightning talk').is_keynote?).to be false
    end
    it "is false when name is Short talk" do
      expect(create_sut('Short talk').is_keynote?).to be false
    end
    it "is true when name is Keynote" do
      expect(create_sut('Keynote').is_keynote?).to be true
    end

  end
  describe "is_lightning_talk?" do
    it "is false when Short talk" do
      expect(create_sut('Short talk').is_lightning_talk?).to be false
    end
    it "is false when Keynote" do
      expect(create_sut('Keynote').is_lightning_talk?).to be false
    end
    it "is true when Lightning talk" do
      expect(create_sut('Lightning talk').is_lightning_talk?).to be true
    end
  end
end
