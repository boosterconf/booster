require 'test_helper'

class RootsMailerTest < ActionMailer::TestCase
  user = User.new :email => "oc+brsseb@me.com", :name => "Bjørn Christian Sebak"
  test "registration_confirmation" do
    @expected = load_erb_template('registration_confirmation', lambda do
      @name  = user.name
      @email = user.email
      lambda {}
    end)
    assert_equal @expected, RootsMailer.create_registration_confirmation(user).body
  end

  test "payment_confirmation" do
    user              = User.new :email => "oc+brsseb@me.com", :name => "Bjørn Christian Sebak"

    registration      = user.create_registration :user        => user,
                                                 :ticket_type_old => "full_price", :includes_dinner => true
    expected          = load_erb_template('payment_confirmation', lambda do
      @name         = user.name
      @amount       = registration.price
      @payment_text = registration.description
      lambda {}
    end)
    registration.user = user

    assert_equal expected, RootsMailer.create_payment_confirmation(registration).body
  end

  test "talk_confirmation" do

    user = User.new :email => "oc+brsseb@me.com", :name => "Bjørn Christian Sebak"
    talk = Talk.new :title => "A fine talk"
    talk.users << user
    talk_url  = "http://rootsconf.no/talks/1234"

    @expected = load_erb_template('talk_confirmation', lambda do
      @speaker  = user.name
      @email    = user.email
      @talk     = talk.title
      @talk_url = talk_url
      lambda {}
    end)
    assert_equal @expected,
                 RootsMailer.create_talk_confirmation(talk, talk_url).body
  end

  test "comment_notification" do
    user = User.new :email => "oc+brsseb@me.com", :name => "Bjørn Christian Sebak"
    talk = Talk.new :title => "A fine talk"
    talk.users << user
    comment     = Comment.new :talk => talk
    comment_url = "http://rootsconf.no/talks/1234#comment_1"

    @expected   = load_erb_template('comment_notification', lambda do
      @speaker     = user.name
      @talk        = talk.title
      @comment_url = comment_url
      lambda {}
    end)

    assert_equal @expected, RootsMailer.create_comment_notification(comment, comment_url).body
  end

  def load_erb_template(file_name, vars)
    template = ERB.new File.new(File.join(RAILS_ROOT, 'app', 'views', 'roots_mailer', "#{file_name}.erb")).read, nil, "%"
    template.result(vars.call)
  end

end
