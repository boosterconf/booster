class TagsController < ApplicationController
  before_action :require_user, :only => [:new, :create]
  before_action :require_admin, :only => [:index, :edit, :update, :destroy]
  # Anybody can see :show and :create

  # GET /tags
  def index
    @tags = Tag.all(order => "title")
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def create
    @tag = Tag.new(params[:tag])
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag updated.'
        format.html { redirect_to(tags_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @tag = Tag.find(params[:id])
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag updated.'
        format.html { redirect_to(tags_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

end
