require 'test_helper'

class RootsMailerTest < ActionMailer::TestCase
  user = User.new :email => "oc+brsseb@me.com", :name => "Bjorn Christian Sebak"

  test "updated actionmailer" do
    email = BoosterMailer.reminder_to_earlier_participants_email(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "Remember to sign up for Booster 2013 before the Early Bird deadline!", email.subject
    assert_match(/Hi #{user.name}/, email.encoded)
  end

  test "registration_confirmation" do
    user = User.new :email => "oc+brsseb@me.com", :name => "Bjorn Christian Sebak"
    email = BoosterMailer.registration_confirmation(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    expected = load_erb_template('registration_confirmation', lambda do
      @name  = user.name
      @email = user.email
      lambda {}
    end)
    assert_equal expected, email.encoded
  end

  test "payment_confirmation" do
    user = User.new :email => "oc+brsseb@me.com", :name => "Bjorn Christian Sebak"
    registration      = user.create_registration :user        => user,
                                                 :ticket_type_old => "full_price", :includes_dinner => true

    email = BoosterMailer.payment_confirmation(registration).deliver
    assert !ActionMailer::Base.deliveries.empty?

    expected          = load_erb_template('payment_confirmation', lambda do
      @name         = user.name
      @amount       = registration.price
      @payment_text = registration.description
      lambda {}
    end)
    registration.user = user

    assert_equal expected, email.encoded
  end

  test "talk_confirmation" do
    user = User.new :email => "oc+brsseb@me.com", :name => "Bjorn Christian Sebak"
    talk = Talk.new :title => "A fine talk"
    talk.speaker_name = "A fine speaker"
    talk.users << user
    talk_url  = "http://boosterconf.no/talks/1234"
    email = BoosterMailer.talk_confirmation(talk, talk_url).deliver
    assert !ActionMailer::Base.deliveries.empty?

    expected = load_erb_template('talk_confirmation', lambda do
      @speaker  = user.name
      @email    = user.email
      @talk     = talk.title
      @talk_url = talk_url
      lambda {}
    end)
    assert_equal expected, email.encoded
  end

  test "comment_notification" do
    user = User.new :email => "oc+brsseb@me.com", :name => "Bjorn Christian Sebak"
    talk = Talk.new :title => "A fine talk"
    talk.users << user
    comment     = Comment.new :talk => talk
    comment_url = "http://boosterconf.no/talks/1234#comment_1"
    email = BoosterMailer.comment_notification(comment, comment_url).deliver
    assert !ActionMailer::Base.deliveries.empty?

    expected   = load_erb_template('comment_notification', lambda do
      @speaker     = user.name
      @talk        = talk.title
      @comment_url = comment_url
      lambda {}
    end)

    assert_equal expected, email.encoded
  end

  def load_erb_template(file_name, vars)
    template = ERB.new File.new(File.join(Rails.root, 'app', 'views', 'booster_mailer', "#{file_name}.erb")).read, nil, "%"
    template.result(vars.binding())
  end

end
