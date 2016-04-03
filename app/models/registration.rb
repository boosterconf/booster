class Registration < ActiveRecord::Base
  # TODO: Should perhaps be in some i18n-file somewhere and not hard-coded
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
      'new_speaker' => 'Speaker without abstracts',
      'reviewer' => 'Reviewer ticket for Booster'
  }

  PAYING_TICKET_TYPES = %w(early_bird full_price one_day lightning student reviewer)

  acts_as_paranoid

  attr_accessible :comments, :includes_dinner, :description,
                  :ticket_type_old, :free_ticket, :user_id, :paid_amount, :payment_reference,
                  :manual_payment, :invoice_address, :invoice_description, :invoiced, :registration_complete,
                  :speakers_dinner

  default_scope :order => 'registrations.created_at desc'
  belongs_to :user
  has_one :payment_notification
  belongs_to :invoice
  has_one :invoice_line

  before_create :create_or_update_payment_info
  before_create :set_default_values
  before_destroy :destroy_talks_and_user
  before_restore :restore_talks_and_user

  def set_default_values
    self.manual_payment ||= true
    self.ticket_type_old ||= self.class.current_normal_ticket_type
  end

  def destroy_talks_and_user
    # This is necessary because the callback does not discriminate between
    # destroy and destroy! When we upgrade to Rails 4, this can be removed
    method = self.deleted_at ? :destroy! : :destroy

    if self.user != nil
      talks = self.user.talks
      talks.each do |talk|
        if talk.has_single_speaker?
          talk.send(method)
        end
      end

      self.user.send(method)
    end
  end

  def restore_talks_and_user
    self.user.restore
    self.user.talks.only_deleted.each do |talk|
      talk.restore
    end
  end

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

  def may_attend_speakers_dinner?
    user != nil && user.confirmed_speaker? || reviewer? || organizer?
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

  def reviewer?
      ticket_type_old == 'reviewer'
  end

  def organizer?
    ticket_type_old == 'organizer'
  end

  def normal_ticket?
    %w(early_bird full_price).include? ticket_type_old
  end

  def has_paying_ticket?
    PAYING_TICKET_TYPES.include?(ticket_type_old)
  end

  def paid?
    paid_amount && paid_amount > 0
  end

  def complete!(current_user)
    self.registration_complete = true
    self.completed_by = current_user.email
  end

  def self.find_by_invoice(invoice_id)
    if invoice_id =~ /^2016t?-(\d+)$/
      Registration.find($1.to_i)
    else
      raise 'Invalid invoice_id #{invoice_id}'
    end
  end

  def invoice_id
    return '2016-#{id}' if Rails.env == 'production'
    '2016t-#{id}'
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

  def self.current_normal_ticket_type
    early_bird_is_active? ? "early_bird" : "full_price"
  end

  def self.early_bird_is_active?
    Time.now < AppConfig.early_bird_ends
  end

  def user
    User.unscoped { super }
  end
end
