class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :logged_in?, :admin?, :reviewer?, :admin_reviewer_or_talk_owner?

  before_filter :load_sponsors

  private
  LOOKS_NUMBER_LIKE = /^[-+]?[1-9]([0-9]*)?$/

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def load_sponsors
    @our_sponsors = Sponsor.all_accepted.select { |sponsor| sponsor.should_show_logo? }
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

  def reviewer?
    current_user and current_user.reviewer?
  end

  def admin_reviewer_or_talk_owner?(talk)
    admin_or_reviewer? || talk.is_presented_by?(current_user)
  end

  def admin_or_reviewer?
    return false unless current_user

    current_user.is_admin || current_user.reviewer?
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

  def require_reviewer_admin_or_self

    return access_denied unless current_user

    if params[:talk_id] =~ LOOKS_NUMBER_LIKE
      talk = Talk.find(params[:talk_id], include: :users)
      unless admin_or_reviewer? || talk.is_presented_by?(current_user)
        flash[:error] = 'Shame on you!'
        return access_denied
      end
    else
      unless admin_or_reviewer?
        flash[:error] = 'Shame on you!'
        return access_denied
      end
    end
  end

  def require_admin_or_speaker
    unless params[:id] == 'favicon'
      user = User.find(params[:id])

      unless current_user.is_admin? || user.registration.ticket_type_old == 'speaker'
        flash[:error] = "Speakers only!"
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

  private
  def cached_sponsors
    Rails.cache.fetch('all_accepted_sponsors', expires_in: 4.hours) do
      Sponsor.all_accepted.select { |sponsor| sponsor.should_show_logo? }
    end
  end
end


