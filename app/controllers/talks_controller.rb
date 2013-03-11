class TalksController < ApplicationController
  before_filter :require_user, :except => [:index, :show, :new, :article_tags]
  before_filter :require_admin, :only => [:assign, :create_assigned, :cheat_sheet]
  before_filter :is_admin_or_owner, :only => [:edit, :update, :destroy]

  def index
    @talks = Talk.all_pending_and_approved
    @lightning_talks = []
    @workshops = []

    @talks.each do |talk|
      if talk.is_lightning_talk?
        @lightning_talks.append(talk)
      else
        @workshops.append(talk)
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @talks }
      format.rss
    end
  end

  def article_tags
    @tags = Tag.all(:order => :title)
    @tag = Tag.find(params[:id])
    @talks = @tag.talks

    respond_to do |format|
      format.html #article_tags
      format.xml { render :xml => @talks }
      format.rss
    end
  end


  def show
    @talk = Talk.find(params[:id], :include => [:users, :comments])
    @comment = Comment.new
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @talk }
    end
  end

  def new
    if current_user
      @talk = Talk.new
      @tags = Tag.all
      @user = current_user
      @types = TalkType.all
    else
      flash[:notice] = 'You have to register a user first!'
      redirect_to register_lightning_talk_start_url
    end
  end

  def edit
    @talk = Talk.find(params[:id])
    @tags = Tag.all
    @user = User.new
    @types = TalkType.all

    action = "edit_lightning_talk"
    if @talk.is_tutorial?
      action = "edit_tutorial"
    end

    respond_to do |format|
      format.html { render :action => action }
    end

  end

  def assign
    @talk = Talk.new
    @tags = Tag.all
    @user = User.find(params[:id])
    @types = TalkType.all
  end

  def create_assigned
    extended_params = params[:talk].merge!({:acceptance_status => "accepted"})

    puts params

    @talk = Talk.new(extended_params)
    @user = User.find(params[:assigned_user_id])
    @tags = Tag.find_all()
    @types = TalkType.all

    # Tag handling
    tag_names = []
    tags = []
    if params[:item] && params[:item][:tags]
      tag_names = params[:item][:tags]
      if params[:uncommited_tag] && params[:uncommited_tag].chomp() != ""
        tag_names.push(params[:uncommited_tag].chomp())
      end
    elsif params[:uncommited_tag] && params[:uncommited_tag].chomp() != ""
      tag_names.push(params[:uncommited_tag].chomp())
    end
    @talk.tags = Tag.create_and_return_tags(tag_names)

    @talk.users << @user

    if @talk.save
      flash[:notice] = "Abstract assigned"
      redirect_to(@talk)
    else
      render :action => "assign"
    end

  end

  def create
    extended_params = params[:talk].merge!({:acceptance_status => "pending"})
    @talk = Talk.new(extended_params)
    @tags = Tag.all
    @types = TalkType.all

    # Tag handling
    tag_names = []
    if params[:item] && params[:item][:tags]
      tag_names = params[:item][:tags]
      if params[:uncommited_tag] && params[:uncommited_tag].chomp() != ""
        tag_names.push(params[:uncommited_tag].chomp())
      end
    elsif params[:uncommited_tag] && params[:uncommited_tag].chomp() != ""
      tag_names.push(params[:uncommited_tag].chomp())
    end
    @talk.tags = Tag.create_and_return_tags(tag_names)
    if current_user
      @user = current_user
      unless @user.registration.special_ticket?
        if @talk.talk_type.eligible_for_free_ticket?
          @user.registration.ticket_type_old = 'speaker'
        elsif @user.registration.ticket_type_old != 'speaker'
          @user.registration.ticket_type_old = 'lightning'
        end
      end
      @user.save
    end

    @talk.users << @user

    if @talk.save
      flash[:notice] = "Abstract published"
      BoosterMailer.talk_confirmation(@talk, talk_url(@talk)).deliver
      redirect_to @talk
    else
      render :action => "new"
    end
  end

  def update
    @talk = current_user.is_admin ? Talk.find(params[:id]) : current_user.talks.find(params[:id])
    @talk.assign_attributes(params[:talk])
    @tags = Tag.all
    @types = TalkType.all

    # Tag handling
    tag_names = []
    if params[:item] && params[:item][:tags]
      tag_names = params[:item][:tags]
      if params[:uncommited_tag] && params[:uncommited_tag].chomp() != ""
        tag_names.push(params[:uncommited_tag].chomp())
      end
    elsif params[:uncommited_tag] && params[:uncommited_tag].chomp() != ""
      tag_names.push(params[:uncommited_tag].chomp())
    end
    @talk.tags = Tag.create_and_return_tags(tag_names)

    respond_to do |format|
      if @talk.update_attributes(params[:talk])
        flash[:notice] = 'Abstract updated.'
        format.html { redirect_to(@talk) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @talk.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @talk = current_user.is_admin ? Talk.find(params[:id]) : current_user.talks.find(params[:id])
    @talk.destroy

    redirect_to(talks_url)
  end

  def cheat_sheet
    @days = Talk.all_accepted_tutorials.find_all { |talk| talk.is_scheduled? }.group_by { |talk| talk.periods[0].day }
  end

  protected
  def login_required
    return unless current_user
    flash[:error] = "Please log in first."
    access_denied
  end

  def is_admin_or_owner
    talk = Talk.find(params[:id])
    unless current_user.is_admin? || talk.users.include?(current_user)
      flash[:error] = "You are required to be the owner of this talk or an administrator to view this page."
      access_denied
    end
  end

end
