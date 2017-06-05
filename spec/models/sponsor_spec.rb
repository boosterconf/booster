require 'rails_helper'

describe Sponsor, type: :model do
  describe "#status_text" do
    it 'is suggested without having a contact email' do
      partner = Sponsor.new
      partner.status = "suggested"

      expect(partner.status_text).to eq('Suggested (missing email)')
    end

    it 'is suggested and has a contact email' do
      partner = Sponsor.new({:email => "partner@example.com"})
      partner.status = "suggested"

      expect(partner.status_text).to eq('Suggested (with email)')
    end

    it 'is in dialogue' do
      partner = Sponsor.new
      partner.status = "dialogue"

      expect(partner.status_text).to eq('In dialogue')
    end
  end

  describe "STATES" do
    it 'maps states to corresponding text' do
      expect(Sponsor::STATES['never']).to eq("Don't ask")
    end
  end

end