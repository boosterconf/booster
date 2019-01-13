class InfoController < ApplicationController
  def speakers
    @speakers = User.all_confirmed_speakers
  end

  def index
    @featured_speakers = User.featured_speakers.shuffle[0...6]
    if(TicketType.early_bird_is_active?)
      @remaining_early_bird_ticket_count = AppConfig.early_bird_ticket_limit - Ticket.count_by_ticket_type(TicketType.early_bird)
    end
  end

  def about
    @organizers = User.featured_organizers.shuffle
  end

end
