class TicketType < ActiveRecord::Base

  TICKET_TEXTS = {
      'early_bird' => 'Early bird ticket for Booster',
      'full_price' => 'Regular ticket for Booster',
      'lightning' => 'Lightning talk ticket for Booster',
      'one_day' => 'One day ticket for Booster',
      'sponsor' => 'Partner ticket Booster',
      'volunteer' => 'Volunteer at Booster',
      'student' => 'Student for Booster',
      'organizer' => 'Organizer for Booster',
      'speaker' => 'Speaker at Booster',
      'academic' => 'Academic ticket Booster',
      'new_speaker' => 'Speaker without abstracts'
  }

  PAYING_TICKET_TYPES = %w(early_bird full_price one_day lightning student)

  has_many :registrations
  attr_accessible :name, :reference, :price

  def speaker?
    %w(lightning speaker).include? reference
  end

  def organizer?
    reference == "organizer"
  end

  def special_ticket?
    %w(sponsor volunteer organizer).include? reference
  end

  def paying_ticket?
    price > 0
  end

  def discounted?
    price < TicketType.find_by_reference("full_price").price
  end

  def self.current_normal_ticket
    early_bird_is_active? ? find_by_reference("early_bird") : find_by_reference("full_price")
  end

  def self.speaker
    find_by_reference("speaker")
  end

  def self.lightning
    find_by_reference("lightning")
  end

  def self.early_bird_is_active?
    Time.now < AppConfig.early_bird_ends
  end
end
