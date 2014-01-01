require 'test_helper'

class ReviewNotifierTest < ActiveSupport::TestCase

  setup do
    @notifier = ReviewNotifier.new
  end

  context 'Notifying create' do

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
      assert_equal last_email['to'].to_s, @talk.speaker_email
    end

    context 'when reviewer is abstract owner herself' do
      should 'not send email to abstract owner' do
        @review.reviewer = @talk.users[0]

        assert_no_difference('ActionMailer::Base.deliveries.size') do
          @notifier.notify_create(@review)
        end
      end
    end


    # TODO What about several speakers on one talk? Will they want to get a notification?

  end

end
