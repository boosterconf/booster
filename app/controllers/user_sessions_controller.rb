class UserSessionsController < ApplicationController

  before_action :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params)
    if @user_session.save
      redirect_back_or_default root_url
    else
      flash[:error] = 'Username or password was not recognized.' if @user_session.errors.any?
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to root_url
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email, :password, :remember_me)
  end

end
