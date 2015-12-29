class SponsorTicketCreator < SimpleDelegator

  def initialize(sponsor)
    @old_status = sponsor.status
    @sponsor = sponsor
    super(@sponsor)
  end

  def save
    @sponsor.save && create_sponsor_tickets
  end

  private
  NUMBER_OF_TICKETS_PER_SPONSOR = 2

  def create_sponsor_tickets
    if status_was_changed_to_accepted
      NUMBER_OF_TICKETS_PER_SPONSOR.times do
        create_single_ticket
      end
    end

    true
  end

  def create_single_ticket
    puts "Creates sponsor ticket for #{@sponsor.name}"
    ticket = User.create_unfinished(nil, 'sponsor')
    ticket.company = @sponsor.name
    ticket.save(validate: false)
  end

  def status_was_changed_to_accepted
    @sponsor.status != @old_status && @sponsor.status == 'accepted'
  end
end
