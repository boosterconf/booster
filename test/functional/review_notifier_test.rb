require 'test_helper'

class ReviewNotifierTest < ActiveSupport::TestCase

  setup do
    @notifier = ReviewNotifier.new
  end

  context 'Notifying on create' do

    setup do
      @talk = talks(:three)

      @review = Review.new
      @review.talk = @talk
    end

    should 'send email to abstract owner' do
      @review.reviewer = users(:god)

      assert_difference('ActionMailer::Base.deliveries.size', +1) do
        @notifier.notify_create(@review)
      end

      last_email = ActionMailer::Base.deliveries.last
      assert_equal last_email['to'].to_s, @talk.speaker_emails
    end

    context 'when reviewer is abstract owner herself' do
      should 'not send email to abstract owner' do
        @review.reviewer = @talk.users[0]

        assert_no_difference('ActionMailer::Base.deliveries.size') do
          @notifier.notify_create(@review)
        end
      end
    end

    context 'on talk with previous reviews' do

      setup do
        new_review = Review.new(talk: @talk)
        new_review.reviewer = users(:reviewer)
        @talk.reviews << new_review

      end

      should 'send email to previous reviewers also' do
        @review.reviewer = users(:god)

        assert_difference('ActionMailer::Base.deliveries.size', +2) do
          @notifier.notify_create(@review)
        end
      end

      should 'not send multiple emails to previous reviewers' do

        another_review = Review.new(talk: @talk)
        another_review.reviewer = users(:reviewer)
        @talk.reviews << another_review

        @review.reviewer = users(:god)

        assert_difference('ActionMailer::Base.deliveries.size', +2) do
          @notifier.notify_create(@review)
        end
      end

    end
  end

end
