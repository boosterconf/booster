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
                      :admin => true
                  })
end

describe "creating an order with a new customer" do

	it "makes the tickets not orderable a second time" do
		user = create_admin_user
    sign_in user

    get root_path

	end
end