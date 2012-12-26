class PasswordResetsController < ApplicationController

  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "An email containing instructions for password reset have been sent to your email address. Please follow the instructions in order to change your password"
      redirect_to root_url
    else
      flash[:error] = "No user with this user name"
      render :action => :new
    end
  end

  def edit
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password updated"
      redirect_to user_url(@user)
    else
      render :action => :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_by_perishable_token(params[:id])
    if not @user
      flash[:notice] = "We're sorry, but we couldn't find the account you requested. Please try again and contact kontakt@rootsconf.no if the problem persists."
      redirect_to root_url
    end
  end
end
