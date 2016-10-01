require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_user_attending_dinner
    quentin = users(:quentin)
    assert !quentin.attending_dinner?

    quentin.attending_dinner!
    assert quentin.attending_dinner?

    quentin.not_attending_dinner!
    assert !quentin.attending_dinner?  
  end

  def test_user_with_one_pending_talk_does_not_have_all_talks_refused
    god = users(:god)
    assert !god.has_all_talks_refused?
  end

  def test_user_with_one_refused_talk_has_all_talks_refused
    test = users(:test)
    test.talks.each { |talk| talk.refuse! }
    assert test.has_all_talks_refused?
  end

  def test_early_user_gets_set_to_early_bird
    quentin = users(:quentin)
    quentin.update_to_paying_user
    assert_equal "early_bird", quentin.registration.ticket_type_old
  end

  def test_late_user_gets_set_to_full_price
    god = users(:god)
    god.update_to_paying_user
    assert_equal "full_price", god.registration.ticket_type_old
  end

  def test_updating_ticket_type_for_user_with_pending_workshop_sets_speaker_ticket_type
    speaker = users(:multispeaker)
    speaker.update_ticket_type!('bogus')
    assert_equal 'speaker', speaker.registration.ticket_type_old
  end

  def test_updating_ticket_type_for_user_with_pending_lightning_talk_sets_lightning_talk_ticket_type
    speaker = users(:test)
    speaker.update_ticket_type!('bogus')
    assert_equal 'lightning', speaker.registration.ticket_type.reference
    assert_equal 'lightning', speaker.registration.ticket_type_old
  end

  def test_invalid_email_is_not_accepted
    user = users(:quentin)
    assert user.has_valid_email?
    assert user.valid?

    user.email = "not a valid email"
    assert !user.has_valid_email?
    assert !user.valid?
  end
end