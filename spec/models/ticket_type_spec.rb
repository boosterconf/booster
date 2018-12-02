require 'rails_helper'

describe TicketType, type: :model do
  def create_with_price(price)
    ticket_type = TicketType.new
    ticket_type.price = price
    ticket_type
  end

  def create_with_reference(reference)
    ticket_type = TicketType.new
    ticket_type.reference = reference
    ticket_type
  end

  describe "paying_ticket?" do
    it "is true when price is greater than zero" do
      expect(create_with_price(100).paying_ticket?).to be true
    end
    it "is false when price is zero" do
      expect(create_with_price(0).paying_ticket?).to be false
    end
  end

  describe "VAT calculations" do
    it "VAT amount" do
      create_with_price(200).vat.should be_within(0.1).of(50)
    end
    it "is total price including VAT" do
      create_with_price(200).price_with_vat.should be_within(0.1).of(250)
    end
  end

  describe "with ticker type reference" do
    it "student reference" do
      expect(create_with_reference("student").student?).to be true
    end
    it "volunteer reference" do
      expect(create_with_reference("volunteer").volunteer?).to be true
    end
    it "organizer reference" do
      expect(create_with_reference("organizer").organizer?).to be true
    end
    it "speaker reference" do
      expect(create_with_reference("speaker").speaker?).to be true
    end
    it "lightning talk speaker reference" do
      expect(create_with_reference("lightning").speaker?).to be true
    end
    it "short talk speaker reference" do
      expect(create_with_reference("short_talk").speaker?).to be true
    end
    it "sponsor special ticket" do
      expect(create_with_reference("sponsor").special_ticket?).to be true
    end
    it "volunteer special ticket " do
      expect(create_with_reference("volunteer").special_ticket?).to be true
    end
    it "organizer special ticket " do
      expect(create_with_reference("organizer").special_ticket?).to be true
    end
    it "early bird with normal ticket" do
      expect(create_with_reference("early_bird").normal_ticket?).to be true
    end
    it "full price with normal ticket" do
      expect(create_with_reference("full_price").normal_ticket?).to be true
    end
    it "sponsor with normal ticket" do
      expect(create_with_reference("sponsor").normal_ticket?).to be true
    end
    it "organizer with normal ticket" do
      expect(create_with_reference("organizer").normal_ticket?).to be true
    end
  end
end
