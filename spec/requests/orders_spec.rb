require 'rails_helper'

def create_admin_user
  return User.create!({
                      :id => 42,
                      :phone_number => "81549300",
                      :first_name => "Speaker",
                      :last_name => "Speakerson",
                      :company => "Company",
                      :email => "email@example.com",
                      :password => "password12345",
                      :password_confirmation => "password12345",
                      :is_admin => true
                  })
end

describe "ordering a ticket" do

	it "is possible to order a ticket" do



	end
end