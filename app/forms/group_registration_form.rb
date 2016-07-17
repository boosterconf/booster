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
  attribute :text
  attribute :company
  attribute :emails

  attr_reader :invoice
  attr_reader :registrations

  validates :delivery_method, presence: true
  validates :zip, presence: true
  validates :email, format: { with: Authlogic::Regex.email }, allow_blank: true

  validates :valid_emails, presence: true
  validates :email, presence: true, if: lambda { |gr| gr.delivery_method == 'email' }
  validates :adress, presence: true, if: lambda { |gr| gr.delivery_method == 'snail_mail' }

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
    @invoice = Invoice.create!(
        email: email,
        adress: adress,
        zip: zip,
        your_reference: your_reference,
        text: text
    )

    @registrations = []

    new_user_emails = emails_string_to_array.reject { |email| user_already_exists(email) }
    new_user_emails.each do |email|
      user = User.create_unfinished(email, Registration.current_normal_ticket_type)
      user.company = company
      user.registration.invoice = @invoice
      @invoice.add_user(user)
      user.save!(validate: false)
      registrations << user.registration
      BoosterMailer.ticket_assignment(user).deliver_now
    end
  end

  def emails_string_to_array
    if emails
      emails.gsub(/[,;:\n]/, " ").split
    else
      []
    end
  end

  def user_already_exists(email)
    User.find_by_email(email)
  end

end