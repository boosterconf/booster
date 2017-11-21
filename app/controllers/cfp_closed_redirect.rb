module CfpClosedRedirect

  def is_lighting_talk_open?
    DateTime.now > Dates::CFP_LIGHTNING_ENDS + 1
  end

  def is_workshop_open?
    DateTime.now > Dates::CFP_TUTORIAL_ENDS + 1
  end

  def redirect_when_cfp_closed_for_lightning_talks
    if is_lighting_talk_open?
      return redirect_to '/'
    end
  end
  
  def redirect_when_cfp_closed_for_workshops
    if is_workshop_open?
      return redirect_to '/'
    end
  end

end