class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :logged_in?, :admin?, :admin_or_talk_owner?

  before_filter :load_sponsors

  private
  LOOKS_NUMBER_LIKE = /^[-+]?[1-9]([0-9]*)?$/

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def load_sponsors
    @our_sponsors = []
    @our_sponsors = Rails.cache.fetch("#our_sponsors", expires_in: 24.hours) do
      sponsors = Sponsor.all_accepted.select {|sponsor| sponsor.should_show_logo?}.to_a
      sponsors.each do |s|
        sponsor = CachedSponsor.new(s.name, s.website, s.logo.url)
        @our_sponsors.push(sponsor)
      end
      @our_sponsors
    end
    @our_sponsors
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def logged_in?
    current_user
  end

  def admin?
    current_user and current_user.is_admin
  end

  def admin_or_talk_owner?(talk)
    admin? || talk.is_presented_by?(current_user)
  end

  def require_admin_or_talk_owner
    talk = Talk.find(params[:id])

    unless admin? || (current_user && talk.is_presented_by?(current_user))
      access_denied
    end
  end

  def require_admin
    unless admin?
      store_location
      redirect_to new_user_session_url, :notice => "You must be a magician to access this page."
      return false
    end
  end

  def require_admin_or_self
    if params[:id] =~ LOOKS_NUMBER_LIKE
      user = User.find(params[:id])
      unless current_user.is_admin? || user == current_user
        flash[:error] = "You are not allowed to look at or edit other users' information"
        access_denied
      end
    end
  end

  def require_user
    unless current_user
      store_location
      redirect_to new_user_session_url, :notice => "You must be logged in to access this page."
      return false
    end
  end

  def require_unauthenticated_or_admin
    if current_user && !current_user.is_admin
      return redirect_to current_user_url
    end
  end

  def store_location
    session[:return_to] = request.url
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def return_to
    session[:return_to]
  end

  def access_denied
    respond_to do |format|
      format.html do
        if current_user
          return redirect_to root_path
        else
          return redirect_to new_user_session_path
        end
      end
      format.any(:json, :xml, :js) do
        return request_http_basic_authentication 'Web Password'
      end
    end
  end

end


