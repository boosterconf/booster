class ReviewsController < ApplicationController

  respond_to :html, :js

  before_filter :require_admin, only: [:index, :destroy]
  before_filter :admin_or_talk_owner, only: [:create, :update]
  before_filter :find_review, only: [:update, :destroy]

  def index
    talks = Talk.talks_for_review

    @workshops, @lightning_talks = talks.partition {|t| t.is_workshop? }

    respond_with @workshops
  end

  def create

    @review = Review.new(review_params)
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
      if @review.update_attributes(review_params)
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { head :no_content }
        format.js { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
        format.js { render json: @review.errors, status: :unprocessable_entity }
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
  def review_params
    params.require(:review).permit(:id, :subject, :text)
#    params.permit(:talk_id)
  end

  def find_review
    @review = Review.find(params[:id])
  end

  def admin_or_talk_owner
      return access_denied unless current_user

      if params[:talk_id] =~ LOOKS_NUMBER_LIKE
        talk = Talk.includes(:users).where(id: params[:talk_id]).first
        unless admin? || talk.is_presented_by?(current_user)
          flash[:error] = 'Shame on you!'
          return access_denied
        end
      else
        unless admin?
          flash[:error] = 'Shame on you!'
          return access_denied
        end
      end
  end

end
