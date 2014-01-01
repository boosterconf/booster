class ReviewNotifier

  def notify_create(review)

    unless review.talk.users.include?(review.reviewer)
      BoosterMailer.review_created(review).deliver
    end
  end

end