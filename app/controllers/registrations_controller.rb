class RegistrationsController < ApplicationController
  before_filter :require_user
  before_filter :require_admin_or_owner, :except => [:index]
  before_filter :require_admin, :only => [:index, :destroy, :restore, :phone_list, :send_welcome_email]

  def index
    @registrations = Registration.find_by_params(params)

    @ticket_types = @registrations.collect { |r| r.ticket_type_old }.uniq

    if @registrations.length > 0
      first_registration = @registrations.min { |x, y| x.created_at.to_date <=> y.created_at.to_date }
      @date_range = (first_registration.created_at.to_date-1..Date.today).to_a
      @all_per_date = total_by_date(@registrations, @date_range)
      @registrations_per_ticket_type_old_per_date = per_ticket_type_old_by_date(@registrations, @date_range)
      @paid_per_date = total_by_date(@registrations, @date_range)

      @income_per_date = total_price_per_date(@registrations, @date_range)
    end
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

  def send_test_welcome_email
    User.find_all_by_email("kjersti.berg@gmail.com").each do |a_user|
      puts a_user
      BoosterMailer.welcome_email(a_user).deliver_now
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

  def edit
    @registration = Registration.find(params[:id])
  end

  # PUT /registrations/1
  # PUT /registrations/1.xml
  def update

    @registration = Registration.find(params[:id])
    puts params[:registration]
    if admin?
      if params[:ticket_change]
        @registration.ticket_type_old = params[:registration][:ticket_type_old]
        #TODO: Need to get reference to correct tickettype object from ui.
        #@registration.ticket_type = params[:registration][:ticket_type_old]
        @registration.includes_dinner = params[:registration][:includes_dinner]
        @registration.update_payment_info
      else
        @registration.completed_by = current_user.email if admin? and @registration.registration_complete
        @registration.registration_complete = params[:registration][:registration_complete]
        @registration.payment_reference = params[:registration][:payment_reference]
        @registration.paid_amount = params[:registration][:paid_amount]
        @registration.invoiced = params[:registration][:invoiced]
        @registration.user.is_admin =
            (@registration.ticket_type_old == "organizer" && @registration.registration_complete)
        @registration.user.save!
      end
    end

    if @registration.update_attributes(params[:registration])
      if admin? && @registration.registration_complete?
        flash[:notice] = "Information updated and confirmation mail sent"

        if @registration.free_ticket?
          BoosterMailer.free_registration_completion(@registration.user).deliver_now
        else
          BoosterMailer.payment_confirmation(@registration).deliver_now
        end
      else
        flash[:notice] = "Information updated"
      end

      redirect_to @registration.user
    else
      flash.now[:error] = 'Unable to update registration'
      render :action => "edit"
    end
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

  def per_ticket_type_old_by_date(registrations, date_range)
    registrations_by_ticket_type_old = registrations.group_by { |u| u.ticket_type_old }
    result = {}
    for ticket_type_old in registrations_by_ticket_type_old.keys
      result[ticket_type_old] = total_by_date(registrations_by_ticket_type_old[ticket_type_old], date_range)
    end
    result
  end

  def total_by_date(registrations, date_range)
    registrations_by_date = registrations.group_by { |u| u.created_at.to_date }
    per_date = []
    total = 0
    for day in date_range do
      total += registrations_by_date[day].size if registrations_by_date[day]
      per_date << total
    end
    per_date
  end

  def total_price_per_date(registrations, date_range)
    registrations_by_date = registrations.group_by { |u| u.created_at.to_date }
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

end
