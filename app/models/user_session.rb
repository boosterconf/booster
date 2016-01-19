class UserSession < Authlogic::Session::Base
  # when this is set to true we avoid leaking usernames for failed login attempts
  generalize_credentials_error_messages true
end
