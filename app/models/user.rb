class User < ActiveRecord::Base
  attr_accessible :accept_optional_email, :accepted_privacy_guidelines, :birthyear, :company, :crypted_password, 
  	:current_login_at, :current_login_ip, :description, :dietary_requirements, :email, :password, :password_confirmation,
  	:failed_login_count, :feature_as_organizer, :featured_speaker, :female, :hometown, 
  	:invited, :is_admin, :last_login_at, :last_request_at, :login_count, :member_dnd, :name, 
  	:password_salt, :perishable_token, :persistence_token, :phone_number, :registration_ip, :role
  
  acts_as_authentic do |c|
    c.login_field = :email
  end

  def self.all_organizers
      self.all.select { |u| u.feature_as_organizer == true }
  end
end
