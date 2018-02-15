require 'ostruct'
require 'yaml'

# Lager et objekt (strengt tatt en struct) av konfigurasjonen - gjør at du kan gjøre fx 'AppConfig.max_users_limit'
# Dette gjør det mulig å mocke kall til konfigurasjonen.
config = OpenStruct.new(YAML.load_file("#{Rails.root}/config/app_config.yml"))
::AppConfig = OpenStruct.new(config.public_send(Rails.env))