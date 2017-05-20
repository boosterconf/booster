module CfpClosedRedirect

  def is_lighting_talk_open?
    DateTime.now > Dates::CFP_LIGHTNING_ENDS
  end

  def redirect_when_cfp_closed
    if is_lighting_talk_open?
      return redirect_to '/'
    end
  end
end