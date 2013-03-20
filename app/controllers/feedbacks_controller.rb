class FeedbacksController < ApplicationController

  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.save
    BoosterMailer.open_feedback_email(@feedback).deliver

    flash[:notice] = 'Thanks!'

    redirect_to root_url
  end

end