source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.14'
gem "authlogic", '~> 3.3.0'
gem 'paperclip', '~>3.0'

gem 'tinymce-rails'
gem 'aws-sdk', '~> 1.3.4'

gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sendregning', :git => "git://github.com/karianne/sendregning.git"

gem 'prawn'
gem 'rails_12factor'

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
  gem 'test-unit'
  gem "minitest"
  gem "minitest-reporters", '>= 0.5.0'
  gem 'shoulda'
  gem "factory_girl_rails", "~> 3.0"
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
end
