class ReviewNotifier

  def notify_create(review)

    previous_reviewers = review.talk.reviews.map(&:reviewer).uniq
    notification_recipients = previous_reviewers
    notification_recipients << review.talk.users unless review.talk.users.include?(review.reviewer)

    notification_recipients.flatten.each do |recipient|
      BoosterMailer.review_created(review, recipient.email).deliver
    end
  end

end