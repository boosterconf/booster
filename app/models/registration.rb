class Registration < ActiveRecord::Base
  # TODO: Should perhaps be in some i18n-file somewhere and not hard-coded
  TICKET_TEXTS = {
      "early_bird"     => "EarlyBird-ticket for Roots 2012",
      "full_price"     => "Ticket for Roots 2012",
      "lightning"      => "Lightning Talk Ticket for Roots 2012",
      "sponsor"        => "Sponsor ticket Roots 2012",
      "volunteer"      => "Volunteer at Roots 2012",
      "student"        => "Student for Roots 2012",
      "mod251"         => "MOD251 Student for Roots 2012",
      "organizer"      => "Organizer for Roots 2012",
      "speaker"        => "Speaker at Roots 2012",
			"new_speaker"        => "Speaker Without Abstracts"
  }

  attr_accessible :comments, :includes_dinner, :description,
                  :ticket_type_old, :free_ticket, :user_id,
                  :manual_payment, :invoice_address, :invoice_description

  default_scope :order => 'registrations.created_at desc'
  belongs_to :user
  has_one :payment_notification

  # validates_presence_of :invoice_address, :if => Proc.new { |reg| reg.manual_payment }

  before_create :create_or_update_payment_info

  def ticket_description
    TICKET_TEXTS[self.ticket_type_old] || ticket_type_old
  end

  def ticket_price
    PAYMENT_CONFIG[:prices][ticket_type_old].to_i
  end

  def description
    ticket_description + " " + (registration_complete ? " (Paid)" : "")
  end

  def speaker?
    ticket_type_old == "speaker" || ticket_type_old == "lightning"
  end

  def free_ticket
    ticket_price == 0
  end

  def student?
    %w(student mod251).include? ticket_type_old
  end

  def discounted_ticket?
    %w(student lightning mod251).include? ticket_type_old
  end

  def special_ticket?
    %w(sponsor volunteer organizer).include? ticket_type_old
  end

  def normal_ticket?
    %w(early_bird full_price).include? ticket_type_old
  end

  def paid?
    paid_amount && paid_amount > 0
  end

  def complete!(current_user)
    self.registration_complete = true
    self.completed_by = current_user.email
  end

  def self.find_by_invoice(id)
    Registration.find(id.to_i - self.invoice_prefix)
  end

  def self.invoice_prefix
    invoice_start = Time.new.year if Rails.env == "production"
    invoice_start ||= 0
    invoice_start
  end

  def payment_url(payment_notifications_url, return_url)
    values = {
        :business      => PAYMENT_CONFIG[:paypal_email],
        :cmd           => '_cart',
        :upload        => '1',
        :currency_code => 'NOK',
        :notify_url    => payment_notifications_url,
        :return        => return_url,
        :invoice       => id + Registration.invoice_prefix,
        :amount_1      => price,
        :item_name_1   => description,
        :item_number_1 => '1',
        :quantity_1    => '1'
    }

    PAYMENT_CONFIG[:paypal_url] +"?"+values.map do
    |k, v|
      "#{k}=#{CGI::escape(v.to_s)}"
    end.join("&")
  end

  def status
    paid? ? "Paid" : (
    registration_complete? ? "Approved" : (
    manual_payment? && !invoiced ? "To be invoiced" : (
    manual_payment? ? "Already invoiced" : "Must follow up")))
  end

  def self.find_by_params(params)
    if params[:conditions]
      find(:all, :conditions => params[:conditions], :include => :user)
    elsif params[:filter]
      case params[:filter]
        when "skal_foelges_opp"
          return find(:all,
                      :conditions => {:free_ticket => false, :registration_complete => false, :manual_payment => false},
                      :include    => :user)
        when "skal_faktureres"
          return find(:all,
                      :conditions => {:free_ticket => false, :registration_complete => false, :manual_payment => true, :invoiced => false},
                      :include    => :user)
        when "dinner"
          return find(:all, :conditions => "includes_dinner = 1")
        else
          return []
      end
    else
      find(:all, :include => :user)
    end
  end

  def create_or_update_payment_info
    p "Hello!!"
    if paid?
      raise "Cannot change a completed payment!"
    end
    self.registration_complete = false
    update_price
    true
  end

  def update_price
    self.price       = ticket_price
    self.free_ticket = price == 0
  end
end
