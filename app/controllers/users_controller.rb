class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create, :from_reference]
  before_action :require_admin, only: [:index, :delete_bio]
  before_action :require_admin_or_self, only: [:show, :edit, :update]
  before_action :require_unauthenticated_or_admin, only: [:new, :create]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json {render json: @users}
    end
  end

  def show
    if params[:id] == 'current'
      @user = current_user
    else
      @user = User.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json {render json: @user}
    end
  end

  def new
    @user = User.new
    if params[:invited] && current_user.is_admin?
      @user.invited = true
      @user.build_bio
    else
      redirect_to root_path
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    User.transaction do
      @user = User.new(user_params)
      @user.email.strip! if @user.email.present?
      @user.registration_ip = request.remote_ip
      @user.roles = params[:roles].join(",") if params[:roles]

      if @user.invited && current_user.is_admin?
        @user.invite_speaker
      end

      if @user.save

        if @user.invited
          flash[:notice] = "You have registered #{@user.email}"
          redirect_to @user
        end
      else
        flash[:error] = "An error occured. Please follow the instructions below."
        render action: :new
      end
    end
  end

  def login(user)
    UserSession.create(user)
  end

  def create_bio
    @user = User.find(params[:id])

    unless @user.bio
      @user.build_bio.save
    end

    render action: :edit
  end

  def update
    @user = User.find(params[:id])
    @user.roles_will_change!
    @user.roles = params[:roles].join(",") if params[:roles]
    @user.assign_attributes(user_params)

    if @user.save
      flash[:notice] = 'Updated profile.'
      redirect_to @user
    else
      render action: :edit
    end
  end

  def updated_dinner_attendance(dinner_status)
    flash[:notice] = "Thank you for updating your dinner attendance. #{dinner_status}"
    redirect_to current_user_path
  end

  def attending_dinner
    current_user.attending_dinner!
    updated_dinner_attendance("You are registered as attending the dinner.")
  end

  def not_attending_dinner
    current_user.not_attending_dinner!
    updated_dinner_attendance("You are registered as not attending the dinner")
  end

  def attending_speakers_dinner
    current_user.attending_speakers_dinner(true)
    updated_dinner_attendance("You are registered as attending the dinner.")
  end

  def not_attending_speakers_dinner
    current_user.attending_speakers_dinner(false)
    updated_dinner_attendance("You are registered as not attending the dinner")
  end

  def delete_bio
    @user = User.find(params[:id])
    var = if @user.bio.delete
            flash[:notice] = 'Removed bio'
          else
            flash[:notice] = "Couldn't remove bio"
          end
    redirect_to @user
  end

  def new_skeleton
    @user = User.new
  end

  def create_skeleton
    # TODO put unique reference in user table instead of registration for skeleton users.
    email = params[:user][:email]

    if email.present? && User.find_by_email(email)
      flash[:error] = "This email already has a user"
      render action: 'new_skeleton'
    else
      @user = User.create_unfinished(email, params[:user][:first_name], params[:user][:last_name])
      @user.company = params[:user][:company]
      @user.save!(:validate => false)

      flash[:notice] = "Skeleton user created - creation link is #{user_from_reference_url(@user.unique_reference)}"
      redirect_to new_skeleton_user_path

    end
  end

  def all_emails_are_valid(users)
    users.each do |user|
      return false unless user.has_valid_email? && !user_already_exists(user.email)
    end
    true
  end

  def user_already_exists(email)
    User.find_by_email(email)
  end

  def from_reference
    # TODO investigate if from_reference is still used or can be removed.
    if current_user
      redirect_to current_user_url
      return
    end

    #registration = Registration.includes(:user).where(unique_reference: params[:reference]).to_a.first

    # unless registration.present?
    #   flash[:error] = "This link does no longer work"
    #   return
    # end
    #
    # login registration.user
    #
    # redirect_to edit_user_path registration.user
  end

  private

  def user_params
    params.require(:user).permit(:accept_optional_email, :accepted_privacy_guidelines, :birthyear, :company, :crypted_password,
                                 :current_login_at, :current_login_ip, :description, :dietary_requirements, :email,
                                 :password, :password_confirmation, :city, :zip,
                                 :failed_login_count, :feature_as_organizer, :featured_speaker, :gender, :hometown,
                                 :invited, :is_admin,
                                 :phone_number, :registration_ip, :roles,
                                 :first_name, :last_name, :hear_about,
                                 registration_attributes: [:id, :ticket_type_id],
                                 bio_attributes: [
                                     :id, :picture, :tempfile, :original_filename, :content_type, :headers, :title,
                                     :twitter_handle, :blog, :bio
                                 ])
  end
end
