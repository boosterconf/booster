class Registration < ActiveRecord::Base


  acts_as_paranoid

  attr_accessible :comments, :includes_dinner, :description,
                  :free_ticket, :user_id, :paid_amount, :payment_reference,
                  :manual_payment, :invoice_address, :invoice_description, :invoiced, :registration_complete,
                  :speakers_dinner

  default_scope  { order('registrations.created_at desc') }
  belongs_to :user
  belongs_to :invoice
  has_one :invoice_line
  belongs_to :ticket_type

  before_create :set_default_values
  before_destroy :destroy_talks_and_user
  before_restore :restore_talks_and_user

  def set_default_values
    self.manual_payment ||= true
    self.ticket_type_old ||= self.class.current_normal_ticket_type
    self.ticket_type ||= TicketType.current_normal_ticket
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
    ticket_type.name
  end

  def ticket_price
    ticket_type.price
  end

  def description
    ticket_description + ' ' + (registration_complete ? ' (Paid)' : '')
  end

  def speaker?
    ticket_type.speaker?
  end

  def may_attend_speakers_dinner?
    user != nil && ticket_type != nil && (ticket_type.speaker? || ticket_type.organizer?)
  end

  def free_ticket
    !ticket_type.paying_ticket?
  end

  def dinner_included?
    ticket_type.dinner_included
  end

  def discounted_ticket?
    ticket_type.discounted?
  end

  def special_ticket?
    ticket_type.special_ticket?
  end

  def organizer?
    ticket_type.organizer?
  end

  def has_paying_ticket?
    ticket_type.paying_ticket?
  end

  def paid?
    paid_amount && paid_amount > 0
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

  def update_payment_info
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
    TicketType.current_normal_ticket.reference
  end

  def user
    User.unscoped { super }
  end
end
