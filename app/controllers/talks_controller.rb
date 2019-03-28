class TalksController < ApplicationController
  before_action :require_user, :except => [:index, :show, :new, :article_tags, :workshops, :lightning_talks, :accepted]
  before_action :require_admin, :only => [:assign, :create_assigned, :cheat_sheet]
  before_action :is_admin_or_owner, :only => [:edit, :update, :destroy]

  before_action :setup_talk_types, only: [:edit, :update]

  respond_to :html

  def index
    @talks = Talk.all_pending_and_approved
    @lightning_talks = @talks.select(&:is_lightning_talk?)
    @workshops = @talks.select(&:is_workshop?)
    @short_talks = @talks.select(&:is_short_talk?)
  end

  def article_tags
    @tags = Tag.all(order: :title)
    @tag = Tag.find(params[:id])
    @talks = @tag.talks
  end

  def show
    @talk = Talk.includes(:users, :reviews).find(params[:id])
    @review = Review.new
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
    action = ''
    if (@talk.talk_type.is_short_talk?)
      action= 'edit_short_talk'
    elsif @talk.talk_type.is_lightning_talk?
      action = 'edit_lightning_talk'
    elsif @talk.is_workshop?
      action= 'edit_workshop'
    elsif @talk.is_keynote?
      action= 'edit_keynote'
    end
    render action: action
  end

  def assign
    @talk = Talk.new
    @tags = Tag.all
    @user = User.find(params[:user_id])
    @types = TalkType.all
  end

  def create_assigned
    params[:talk].merge!({acceptance_status: 'accepted', language: 'english'})

    @talk = Talk.new(talk_params)
    @user = User.find(params[:user_id])
    @types = TalkType.all

    @talk.users << @user

    if @talk.save
      flash[:notice] = 'Abstract assigned'
      redirect_to @talk
    else

      render action: :assign
    end

  end

  def update
    @talk = current_user.is_admin ? Talk.find(params[:id]) : current_user.talks.find(params[:id])

    @talk.assign_attributes(talk_params)
    @talk.appropriate_for_roles = params[:appropriate_for_roles].join(',') if params[:appropriate_for_roles]
    @tags = Tag.all
    @types = TalkType.all

    # TODO I'm so sorry...
    @talk.type = case @talk.talk_type.name
                   when "Short talk"
                     ShortTalk.name
                   when "Lightning talk"
                     LightningTalk.name
                   when "Keynote"
                     Keynote.name
                   else
                     Workshop.name
                 end

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

    if @talk.update_attributes(talk_params)
      flash[:notice] = 'Abstract updated.'
      redirect_to(@talk)
    else
      render action: @talk.is_workshop? ? 'edit_tutorial' : 'edit_lightning_talk'
    end
  end

  def destroy
    @talk = current_user.is_admin ? Talk.find(params[:id]) : current_user.talks.find(params[:id])
    @talk.destroy

    redirect_to(talks_url)
  end

  def cheat_sheet
    @talks = Talk.all_accepted_tutorials
  end

  def workshops
    @talks = Talk.all_accepted_tutorials
  end

  def lightning_talks
    @talks = Talk.all_accepted_lightning_talks
  end

  def accepted
    @talks = Talk.all_confirmed
    @lightning_talks = @talks.select(&:is_lightning_talk?)
    @workshops = @talks.select(&:is_workshop?)
    @short_talks = @talks.select(&:is_short_talk?)
  end

  protected
  def is_admin_or_owner
    talk = Talk.find(params[:id])
    unless current_user.is_admin? || talk.users.include?(current_user)
      flash[:error] = 'You are required to be the owner of this talk or an administrator to view this page.'
      access_denied
    end
  end

  def setup_talk_types
    @talk_types = current_user.is_admin? ? TalkType.all : TalkType.workshops
  end

  private
  def talk_params
    params.require(:talk).permit(:talk_type, :talk_type_id, :language, :title, :description, :audience_level, :max_participants,
                                 :participant_requirements, :equipment, :room_setup, :accepted_guidelines, :acceptance_status,
                                 :slide, :outline, :appropriate_for_roles, :speakers_confirmed, :speaking_history, :video_url, :hasSlides)
  end
end
