source 'https://rubygems.org'

ruby '~>2.5'

gem 'rails', '~>6.0.0'
gem "devise", ">= 4.6.1"
gem "devise-encryptable"
gem "devise-scrypt"
gem 'paperclip', '~>5.0'
gem 'aws-sdk', '~> 2.3.0'

# Lock these gems to
gem 'loofah', '~> 2.2.3'
gem 'rails-html-sanitizer', '>= 1.2.0'

# Security requirement
gem "nokogiri", ">= 1.10.4"

gem 'stripe', ">= 5.14.0"
gem "agaon"

gem 'responders', '~> 3.0'

gem 'bootstrap', '= 4.0.0.alpha2'

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

gem 'tinymce-rails'
gem 'selectize-rails'
gem "font-awesome-rails"

gem 'coffee-rails'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter'

gem 'prawn', "~>2.2.2"
gem 'rails_12factor'
gem 'rest-client', '~> 2.0.2'

gem "paranoia", "~> 2.4.2"
gem 'test-unit'

gem 'virtus'
gem 'pg', "= 0.21.0"
#gem 'webpacker'
gem 'react-rails'

gem 'sidekiq'

group :production do
  gem 'heroku-deflater'
  gem 'thin'
end

group :development, :test do
  gem 'debase'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'rails-controller-testing'
  gem 'sqlite3'
  #gem 'quiet_assets'
  gem 'dotenv-rails'
  #gem 'sql_queries_count'
  gem 'bullet'
  gem 'rspec-rails', '~> 3.7'
  gem 'ruby-debug-ide'
  gem 'byebug'

  gem 'flamegraph'
  gem 'rack-mini-profiler'
  gem 'stackprof'
end

group :test do
  gem 'mocha', :require => false
  gem 'minitest', '~>5.10.3'
  gem "minitest-reporters", '~> 1.1'
  gem 'shoulda'
  gem "factory_girl_rails", "~> 3.0"
  gem 'rake'
  gem 'simplecov'
end

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
gem 'sass-rails' #, '~> 3.2.3'
#end
