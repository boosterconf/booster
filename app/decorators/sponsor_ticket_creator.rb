class SponsorTicketCreator < SimpleDelegator

  def initialize(sponsor)
    @sponsor = sponsor
    super(@sponsor)
  end

  def save
    @sponsor_was_set_to_accepted = @sponsor.status_changed? && @sponsor.status == 'accepted' # status_changed only works for unsaved objects
    @sponsor.save && create_sponsor_tickets
  end

  private
  NUMBER_OF_SPONSOR_TICKETS = 2

  def create_sponsor_tickets
    if @sponsor_was_set_to_accepted
      NUMBER_OF_SPONSOR_TICKETS.times do
        create_single_ticket
      end
    end
  end

  def create_single_ticket
    puts "Creates sponsor ticket for #{@sponsor.name}"
    ticket = User.create_unfinished(nil, 'sponsor')
    ticket.company = @sponsor.name
    ticket.save!(validate: false)
  end

end