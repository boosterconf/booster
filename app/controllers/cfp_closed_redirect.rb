module CfpClosedRedirect

  def is_lighting_talk_open?
    Date.current > Dates::CFP_LIGHTNING_ENDS
  end

  def is_workshop_open?
    Date.current > Dates::CFP_TUTORIAL_ENDS
  end

  def redirect_when_cfp_closed_for_lightning_talks
    if is_lighting_talk_open?
      redirect_to :root
    end
  end

  def redirect_when_cfp_closed_for_workshops
    if is_workshop_open?
      redirect_to :root
    end
  end
end
