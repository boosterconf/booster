Booster2013::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  
  config.action_mailer.default_url_options = {
      :host => '127.0.0.1',
      :port => 3000
  }
  
  config.eager_load = false
  
  config.action_mailer.delivery_method = :file

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = true

  Paperclip.options[:command_path] = "/usr/local/bin/"

  config.after_initialize do
      Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  end

  config.before_configuration do
    env_file = File.join(Rails.root, 'local_env.yml')
    YAML.load(File.open(env_file)).each do |key, value|
      ENV[key.to_s] = value
    end if File.exists?(env_file)
  end
end
