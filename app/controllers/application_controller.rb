class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper :all 
  helper_method :current_user_session, :current_user

	def current_user_session
	  return @current_user_session if defined?(@current_user_session)
	  @current_user_session = UserSession.find
	end

	def current_user
	  return @current_user if defined?(@current_user)
	  @current_user = current_user_session && current_user_session.record
	end

  def admin?
    current_user and current_user.is_admin
  end

	def require_admin
		unless admin?
	    	store_location
	    	redirect_to new_user_session_url, :notice => "I'm sorry, but that page is not meant for you."
	    return false
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
end
