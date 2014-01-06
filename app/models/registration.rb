class Registration < ActiveRecord::Base
  # TODO: Should perhaps be in some i18n-file somewhere and not hard-coded
  TICKET_TEXTS = {
      'early_bird' => 'Early bird ticket for Booster 2014',
      'full_price' => 'Regular ticket for Booster 2014',
      'lightning' => 'Lightning talk ticket for Booster 2014',
      'sponsor' => 'Sponsor ticket Booster 2014',
      'volunteer' => 'Volunteer at Booster 2014',
      'student' => 'Student for Booster 2014',
      'organizer' => 'Organizer for Booster 2014',
      'speaker' => 'Speaker at Booster 2014',
      'academic' => 'Academic ticket Booster 2014',
      'new_speaker' => 'Speaker without abstracts',
      'reviewer' => 'Reviewer ticket for Booster 2014'
  }

  attr_accessible :comments, :includes_dinner, :description,
                  :ticket_type_old, :free_ticket, :user_id, :paid_amount, :payment_reference,
                  :manual_payment, :invoice_address, :invoice_description, :invoiced, :registration_complete

  default_scope :order => 'registrations.created_at desc'
  belongs_to :user
  has_one :payment_notification
  belongs_to :invoice

  #validates_presence_of :invoice_address, :if => Proc.new { |reg| reg.manual_payment }
  #validates_presence_of :user 

  before_create :create_or_update_payment_info

  def ticket_description
    TICKET_TEXTS[self.ticket_type_old] || ticket_type_old
  end

  def ticket_price
    PAYMENT_CONFIG[:prices][ticket_type_old].to_i
  end

  def description
    ticket_description + ' ' + (registration_complete ? ' (Paid)' : '')
  end

  def speaker?
    ticket_type_old == 'speaker' || ticket_type_old == 'lightning'
  end

  def free_ticket
    ticket_price == 0
  end

  def student?
    %w(student mod251).include? ticket_type_old
  end

  def discounted_ticket?
    %w(student lightning mod251 reviewer).include? ticket_type_old
  end

  def special_ticket?
    %w(sponsor volunteer organizer reviewer).include? ticket_type_old
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

  def self.find_by_invoice(invoice_id)
    if invoice_id =~ /^2014t?-(\d+)$/
      Registration.find($1.to_i)
    else
      raise 'Invalid invoice_id #{invoice_id}'
    end
  end

  def invoice_id
    return '2014-#{id}' if Rails.env == 'production'
    '2014t-#{id}'
  end

  def payment_url(payment_notifications_url, return_url)
    values = {
        :business => PAYMENT_CONFIG[:paypal_email],
        :cmd => '_cart',
        :upload => '1',
        :currency_code => 'NOK',
        :notify_url => payment_notifications_url,
        :return => return_url,
        :invoice => invoice_id,
        :amount_1 => price_including_vat,
        :item_name_1 => description,
        :item_number_1 => '1',
        :quantity_1 => '1'
    }

    PAYMENT_CONFIG[:paypal_url] +'?'+values.map do
    |k, v|
      '#{k}=#{CGI::escape(v.to_s)}'
    end.join('&')
  end

  def price_including_vat
    price * 1.25
  end

  def status
    paid? ? 'Paid' : (
    registration_complete? ? 'Approved' : (
    manual_payment? && !invoiced ? 'To be invoiced' : (
    manual_payment? ? 'Already invoiced' : 'Must follow up')))
  end

  def self.find_by_params(params)
    puts params
    if params[:conditions]
      return where(params[:conditions])
    elsif params[:filter]
      case params[:filter]
        when 'completed'
          return where( { :registration_complete => true })
        when 'not_completed'
          return where( { :registration_complete => false })
        when 'er_fakturert'
          return where(
            {
              :free_ticket => false, 
              :registration_complete => false, 
              :manual_payment => true, 
              :invoiced => true
            })
        when 'skal_foelges_opp'
          return where(
            {
              :free_ticket => false, 
              :registration_complete => false, 
              :manual_payment => false
            })
        when 'skal_faktureres'
          return where(
            {
              :free_ticket => false, 
              :registration_complete => false, 
              :manual_payment => true, 
              :invoiced => false
            })
        when 'dinner'
          return where(:includes_dinner => true)
        else
          return []
      end
    else
      all
    end
  end

  def create_or_update_payment_info
    if paid?
      raise 'Cannot change a completed payment!'
    end
    self.registration_complete = false
    update_price
    true
  end

  def update_price
    self.price = ticket_price
    self.free_ticket = price == 0
  end
end
