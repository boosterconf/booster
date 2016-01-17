class SponsorStatusEventCreator < SimpleDelegator

  def initialize(sponsor:, user:)
    @sponsor = sponsor
    @user = user
    @old_status = sponsor.status
    super(@sponsor)
  end

  def save
    @sponsor.save && create_status_change_event
  end

  private
  def create_status_change_event
    if @sponsor.status != @old_status
      Event.create!(user: @user, sponsor_id: @sponsor.id, comment: "Partner status changed to #{@sponsor.status_text}")
    end

    true
  end

end