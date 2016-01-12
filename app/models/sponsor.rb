class Sponsor < ActiveRecord::Base

  belongs_to :user
  has_many :events, dependent: :destroy
  has_one :invoice_line

  attr_accessible :comment, :contact_person_first_name, :contact_person_last_name, :contact_person_phone_number,
                  :email, :last_contacted_at, :location, :name, :status, :user_id,
                  :was_sponsor_last_year, :events, :logo, :publish_logo, :website

  has_attached_file :logo, PAPERCLIP_CONFIG.merge({
                                                      styles: {
                                                          :normal => '150x'
                                                      },
                                                      :default_style => :normal,
                                                      convert_options: {
                                                          s3_headers: { 'Cache-Control' => 'max-age=2592000', 'Expires' => 30.days.from_now.httpdate }
                                                      }
                                                  })
  validates_attachment_content_type :logo,
                                    :content_type =>
                                        %w(image/jpg image/jpeg image/pjpeg image/gif image/png image/x-png),
                                    :message => 'only image files are allowed'

  STATES = {
      'suggested' => 'Suggested',
      'dialogue' => 'In dialogue',
      'contacted' => 'Contacted',
      'reminded' => 'Reminded',
      'declined' => 'Declined',
      'accepted' => 'Accepted',
      'never' => "Don't ask"
  }

  def status_text
    state = STATES[status]

    if state == 'Suggested'
      if self.email.present?
        state += ' (with email)'
      else
        state += ' (missing email)'
      end
    end

    state
  end

  def contact_person_name
    "#{contact_person_first_name} #{contact_person_last_name}"
  end

  def self.all_accepted
      self.find_all_by_status('accepted')
  end

  def has_email?
    self.email.present?
  end

  def is_ready_for_email?
    status == 'suggested' && email.present?
  end

  def is_in_bergen?
    location.downcase == 'bergen'
  end

  def accepted?
    self.status == 'accepted'
  end

  def should_show_logo?
    self.publish_logo && self.logo.exists? && self.accepted?
  end

  def contact_person_full_name
    contact_person_first_name + " " + contact_person_last_name
  end

  def <=>(other)
    self.name <=> other.name
  end
end
