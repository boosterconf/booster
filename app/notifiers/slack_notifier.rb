class SlackNotifier
  require 'rest_client'
  require 'nokogiri'

  @@API_URL = ENV['SLACK_URL']
  @@SLACK_TEST_CHANNEL = ENV['SLACK_TEST_CHANNEL']

  @@ENV_LABEL = Rails.env.production? ? '' : " [#{Rails.env.upcase}]"
  @@BOT_NAME = 'Boosterbot' + @@ENV_LABEL


  def self.notify_talk(talk)
    name = talk.users.map(&:name_or_email).join(',')
    talk_type = talk.talk_type.name.downcase
    title = talk.title
    talk_url = Rails.application.routes.url_helpers.talk_url(talk)
    abstract = Nokogiri::HTML.fragment(ActionView::Base.full_sanitizer.sanitize(talk.description)[0..500]).to_s
    if talk.description.length > 500
      abstract = "#{abstract}... <#{talk_url}|read more>"
    end

    body = create_talk_body(name, talk_type, title, abstract, talk_url)
    self.post_talk_notification(@@API_URL, talk_type, body)

  end

  def self.create_talk_body(name, talk_type, title, abstract, talk_url)
     {
        :username => @@BOT_NAME,
        :attachments => [{
            :fallback => "*Good news everyone!* #{name} just proposed a #{talk_type} called <#{talk_url}|#{title}>",
            :pretext => "*Good news, everyone!* #{name} just proposed a #{talk_type} called <#{talk_url}|#{title}>",
            :color => "#9fd07e",
            :mrkdwn_in => ['pretext'],
            :fields => [{
                :title => 'Abstract',
                :value => abstract,
                :short => false,
                :mrkdwn_in => ['value']
            }]
        }]
    }
  end

  def self.post_talk_notification(url, talk_type, body)
    if url

      if @@SLACK_TEST_CHANNEL && !body[:channel]
        body = body.merge({:channel => "#{@@SLACK_TEST_CHANNEL}"})
      end

      t = Thread.new do
        begin
          puts "Posting #{talk_type} to Slack: " + url +  '=>'  + body.to_json

          RestClient.post url, body.to_json, :content_type => :json, :accept => :json

        rescue => e
          message = "Posting #{talk_type} to Slack failed!" +
          "\n\nException: " + e.to_s +
          "\n\nURL: " + url +
          "\n\nPayload: " + body.to_json

          puts message
          BoosterMailer.deliver_error_mail('Failed to post a talk to Slack', message)
        end
      end
    else
      puts "Warning: Environment variable SLACK_URL is not set in #{Rails.env}. Skipping Slack notification."
    end
  end

  def self.notify_sponsor(sponsor)
    name = sponsor.name
    count = Sponsor.where(status: 'accepted').count
    body = {
            :username => @@BOT_NAME,
            :channel => '#sponsors',
            :text => "*Good news everyone!* #{name} has agreed to be a partner! We now have #{count} partners."
        }
    self.post_to_slack(body)
  end

  def self.post_to_slack(body)
    url = @@API_URL
    if url

      if @@SLACK_TEST_CHANNEL && !body[:channel]
        body = body.merge({:channel => "#{@@SLACK_TEST_CHANNEL}"})
      end

      t = Thread.new do
        begin
          puts 'Posting to Slack: ' + url +  '=>'  + body.to_json

          RestClient.post url, body.to_json, :content_type => :json, :accept => :json

        rescue => e
          message = 'Posting to Slack failed!' +
          '\n\nException: ' + e.to_s +
          '\n\nURL: ' + url +
          '\n\nPayload: ' + body.to_json

          puts message
          BoosterMailer.deliver_error_mail('Failed to post a message to Slack', message)
        end
      end
    else
      puts "Warning: Environment variable SLACK_URL is not set in #{Rails.env}. Skipping Slack notification."
    end
  end


  def self.post_reply(params, message)
    channel = params[:channel_name]
    channel = channel == 'directmessage' ? "@#{params[:user_name]}" : "##{channel}"
    body = {
        :username => @@BOT_NAME,
        :channel => channel,
        :text => message
    }
    puts body
    RestClient.post @@API_URL, body.to_json, :content_type => :json, :accept => :json
  end
end