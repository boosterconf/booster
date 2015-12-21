class SponsorAcceptedSlackNotifier < SimpleDelegator

  def initialize(sponsor)
    @old_status = sponsor.status
    @sponsor = sponsor
    super
  end

  def save
    @sponsor.save && notify_slack
  end

  private
  def notify_slack
    if status_was_changed_to_accepted
      count = Sponsor.where(status: 'accepted').count
      body = {
          :channel => '#sponsors',
          :text => "*Good news everyone!* #{@sponsor.name} has agreed to become a partner! We now have #{count} partners."
      }
      SlackNotifier.post_to_slack(body)
    end

    true
  end

  def status_was_changed_to_accepted
    @sponsor.status != @old_status && @sponsor.status == 'accepted'
  end
end
