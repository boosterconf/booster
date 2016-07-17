class CommentsController < ApplicationController
  include ActionView::RecordIdentifier # for dom_id

  before_filter :require_user, :only => [:create, :edit]

  def index
    @comments = params[:talk_id] ? Talk.find(params[:talk_id]).comments : Comment.find(:all)
  end

  def show
    @comment = Comment.find(params[:id], :include => [:talk])
    redirect_to :controller => 'talks', :action => 'show', :id => @comment.talk, :anchor => dom_id(@comment)
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def create
    @talk = Talk.find(params[:talk_id])
    @comment = @talk.comments.new(params[:comment])
    @comment.user = current_user

    if @comment.save
      flash[:notice] = 'Comment created.'
      BoosterMailer.comment_notification(@comment, talk_url(@comment.talk, :anchor => dom_id(@comment))).deliver_now
      redirect_to(:controller => 'talks', :action => 'show', :id => @talk)
    else
      render :template => "talks/show"
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment updated.'
        format.html { redirect_to(@comment) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
end
