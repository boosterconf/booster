class ReviewNotifier

  def notify_create(review)

    previous_reviewers = review.talk.reviews.map(&:reviewer).uniq
    notification_recipients = previous_reviewers.concat(review.talk.users)
    notification_recipients.delete(review.reviewer)

    notification_recipients.each do |recipient|
      BoosterMailer.review_created(review, recipient.email).deliver_now
    end
  end

end