class Sponsor < ActiveRecord::Base
  belongs_to :user
  
  attr_accessible :comment, :contact_person, :contact_person_phone_number, :email, :invoiced, :last_contacted_at, :location, :name, :paid, :status, :user_id, :was_sponsor_last_year

  STATES = { 'suggested' => "Suggested", 'dialogue' => 'In Dialogue', 'contacted' => "Contacted", 'reminded' => "Reminded", 'declined' => "Declined", 'accepted' => "Accepted" }

  def status_text
    STATES[status]
  end

  def self.all_accepted
      self.find_all_by_status("accepted")
  end

  def is_ready_for_email?
    status == "suggested" && email != nil && email != ""
  end

  def is_in_bergen?
    location.downcase == "bergen"
  end

  def <=>(other)
    self.name <=> other.name
  end
end
