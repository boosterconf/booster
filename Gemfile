source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails', '3.2.22'
gem "authlogic", '~> 3.3.0'
gem 'paperclip', '~>3.0'

gem 'tinymce-rails'
gem 'selectize-rails'
gem "font-awesome-rails"
gem 'aws-sdk', '~> 1.3.4'

gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter'

gem 'sendregning', :git => "git://github.com/karianne/sendregning.git"

gem 'prawn'
gem 'rails_12factor'

gem 'rest-client'

gem "paranoia", "~> 1.0"
gem 'test-unit'

gem 'virtus'

group :production do
  gem 'heroku-deflater'
  gem 'pg'
  gem 'thin'
end

group :development, :test do
  gem 'sqlite3'
  gem 'quiet_assets'
  gem 'taps'
end

group :test do
  gem 'mocha', :require => false
  gem 'rspec-rails'
  gem "minitest"
  gem "minitest-reporters", '>= 0.5.0'
  gem 'shoulda'
  gem "factory_girl_rails", "~> 3.0"
	gem 'ruby-prof'
  gem 'rake'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
end
