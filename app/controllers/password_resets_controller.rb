class PasswordResetsController < ApplicationController

  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
    end
    flash[:notice] = "If your email address was found in our system you will receive instructions for resetting your password. Please follow the instructions in order to change your password."
    redirect_to root_url
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
