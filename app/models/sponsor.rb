class Sponsor < ActiveRecord::Base

  belongs_to :user
  has_many :events

  attr_accessible :comment, :contact_person_first_name, :contact_person_last_name, :contact_person_phone_number,
                  :email, :invoiced, :last_contacted_at, :location, :name, :paid, :status, :user_id,
                  :was_sponsor_last_year, :events

  STATES = {
      'suggested' => "Suggested",
      'dialogue' => 'In Dialogue',
      'contacted' => "Contacted",
      'reminded' => "Reminded",
      'declined' => "Declined",
      'accepted' => "Accepted",
      'never' => "Don't ask"
  }

  def status_text
    state = STATES[status]

    if self.accepted?
      if paid != nil
        state = "Paid"
      elsif invoiced != nil
        state = "Invoiced, not paid"
      end
    end

    state
  end

  def contact_person_name
    "#{contact_person_first_name} #{contact_person_last_name}"
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

  def accepted?
    self.status == 'accepted'
  end

  def <=>(other)
    self.name <=> other.name
  end
end
