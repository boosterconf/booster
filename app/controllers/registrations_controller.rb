class RegistrationsController < ApplicationController
  before_action :require_user
  before_action :require_admin_or_owner, :except => [:index]
  before_action :require_admin, :only => [:index, :destroy, :restore, :send_welcome_email]

  def index
    @registrations = Registration.includes(:user).find_by_params(params)
  end

  def deleted
    @registrations = Registration.only_deleted
  end

  def send_welcome_email
    User.all.each do |a_user|
      BoosterMailer.welcome_email(a_user).deliver_now if a_user.email && a_user.first_name
    end
    redirect_to registrations_url
  end

  def send_speakers_dinner_email
    User.all_accepted_speakers.each do |user|
      print "Mailing: #{user.email}...\n"
      BoosterMailer.speakers_dinner_email(user).deliver_now
    end
    redirect_to registrations_url
  end
  
  def update
    @registration = Registration.find(params[:id])
    if admin?
      @registration.registration_complete = params[:registration][:registration_complete]
      @registration.completed_by = current_user.email if @registration.registration_complete
      @registration.user.save!
    end
    flash[:notice] = "Information updated"
    redirect_to @registration.user
  end

  def destroy
    if params[:really]
      really_delete
    else
      soft_delete
    end
  end

  def soft_delete
    @registration = Registration.find(params[:id])
    @registration.destroy

    flash[:notice] = "Soft-deleted user #{@registration.user.full_name}"
    redirect_to registrations_url
  end

  def really_delete
    @registration = Registration.only_deleted.find_by_id(params[:id])

    if @registration

      @registration.user.really_destroy!
      @registration.really_destroy!


      flash[:notice] = "Really deleted user #{@registration.user.full_name}"
      redirect_to deleted_registrations_url
    else
      flash[:notice] = "User not found or must be soft deleted first"
      redirect_to registrations_url
    end
  end

  def restore
    @registration = Registration.with_deleted.find(params[:id])

    @registration.restore

    flash[:notice] = "Restored user #{@registration.user.full_name}"
    redirect_to deleted_registrations_url
  end


  protected
  def require_admin_or_owner
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to see this page"
      redirect_to new_user_session_url
      return false
    end
    @registration = Registration.with_deleted.find(params[:id]) unless params[:id].blank?
    if (@registration && @registration.user == current_user) || admin?
      true
    else
      flash[:notice] = "You are not allowed to see this page"
      redirect_to root_url
      false
    end
  end

  def total_by_date(registrations, date_range)
    registrations_by_date = registrations.group_by {|u| u.created_at.to_date}
    per_date = []
    total = 0
    for day in date_range do
      total += registrations_by_date[day].size if registrations_by_date[day]
      per_date << total
    end
    per_date
  end

  def total_price_per_date(registrations, date_range)
    registrations_by_date = registrations.group_by {|u| u.created_at.to_date}
    per_date = []
    total = 0
    for day in date_range do
      for reg in registrations_by_date[day] || []
        total += reg.paid_amount.to_i || 0
      end
      per_date << total
    end
    per_date
  end

  private
  def registration_params
    params.require(:registration).permit(:comments, :description, :user_id, :registration_complete)
  end
end


