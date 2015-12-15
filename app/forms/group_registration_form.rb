class GroupRegistrationForm
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :delivery_method
  attribute :email
  attribute :adress
  attribute :zip
  attribute :your_reference
  attribute :company
  attribute :emails

  attr_reader :invoice

  validates :delivery_method, presence: true
  validates :zip, presence: true
  validates :email, format: { with: Authlogic::Regex.email }, allow_blank: true

  validate :valid_emails



  def valid_emails
    emails_string_to_array.each do |email|
      errors.add(:emails, "#{email} is not a valid email") unless email.match(Authlogic::Regex.email)
    end
  end

  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def persist!
    @invoice = Invoice.create!(email: email, adress: adress, zip: zip, your_reference: your_reference)
    new_user_emails = emails_string_to_array.reject { |email| user_already_exists(email) }
    new_user_emails.each do |email|
      user = User.create_unfinished(email, Registration.current_normal_ticket_type)
      user.company = company
      user.registration.invoice = @invoice
      user.save!(validate: false)
      BoosterMailer.ticket_assignment(user).deliver
    end
  end

  private
  def emails_string_to_array
    emails.gsub(/[,;:\n]/, " ").split
  end

  def user_already_exists(email)
    User.find_by_email(email)
  end

end