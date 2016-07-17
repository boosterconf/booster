class ReviewsController < ApplicationController

  respond_to :html, :js

  before_filter :require_reviewer_admin_or_self
  before_filter :find_review, only: [:update, :destroy]

  def index
    talks = Talk.all_pending_and_approved

    @workshops, @lightning_talks = talks.partition {|t| t.is_workshop? }

    respond_with @workshops
  end

  def create

    @review = Review.new(params[:review])
    @review.reviewer = current_user
    @review.talk_id = params[:talk_id]

    if @review.save
      @review = Review.includes(:reviewer, :talk).find(@review.id)
      ReviewNotifier.new.notify_create(@review)
      respond_with @review, location: talk_url(@review.talk_id)
    else
      puts 'Oh noes something terrible happened.'
    end
  end

  def update
    respond_to do |format|
      if @review.update_attributes(params[:review])
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @review.destroy

    respond_to do |format|
      format.html { redirect_to reviews_url }
      format.json { head :no_content }
    end
  end

  private
  def find_review
    @review = Review.find(params[:id])
  end

end