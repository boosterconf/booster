require 'rails_helper'

def create_valid_user
  return User.create!({
                      :id => 42,
                      :phone_number => "81549300",
                      :first_name => "Speaker",
                      :last_name => "Speakerson",
                      :company => "Company",
                      :email => "email@example.com",
                      :password => "password12345",
                      :password_confirmation => "password12345"
                  })
end

describe "user session spec" do

	it "signs the user in" do
		user = create_valid_user

    post user_session_path, :params => { :user => { :email => user.email, :password => 'password12345' }}
    expect(response).to redirect_to(root_path)

    follow_redirect!

    expect(response.body).to include("Log out")

	end
end