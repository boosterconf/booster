class SlackNotifier
  require 'rest_client'

  @@API_URL = ENV['SLACK_URL']
  @@SLACK_TEST_CHANNEL = ENV['SLACK_TEST_CHANNEL']

  @@ENV_LABEL = Rails.env.production? ? '' : " [#{Rails.env.upcase}]"
  @@BOT_NAME = 'Boosterbot' + @@ENV_LABEL


  def self.notifyTalk(talk)
    name = talk.speaker_name_or_email
    talk_type = talk.talk_type.name.downcase
    title = talk.title
    talk_url = Rails.application.routes.url_helpers.talk_url(talk)
    abstract = ActionView::Base.full_sanitizer.sanitize(talk.description[0..500])
    if (talk.description.length > 500)
      abstract = abstract + "... <#{talk_url}|read more>"
    end

    body = createTalkBody(name, talk_type, title, abstract, talk_url)
    self.postTalkNotification(@@API_URL, talk_type, body)

  end

  def self.createTalkBody(name, talk_type, title, abstract, talk_url)
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

  def self.postTalkNotification(url, talk_type, body)
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
end