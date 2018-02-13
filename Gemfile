source 'https://rubygems.org'

ruby '2.4.0'

gem 'railties', '5.0.6'
gem 'rails', '5.0.6'
gem "authlogic", '~> 3.8'
gem 'paperclip', '~>5.0'
gem 'aws-sdk', '~> 2.3.0'

gem 'stripe'

gem 'responders', '~> 2.0'

gem 'bootstrap', '= 4.0.0.alpha2'

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

gem 'tinymce-rails'
gem 'selectize-rails'
gem "font-awesome-rails"

gem 'coffee-rails', '~> 4.1.0'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter'

gem 'prawn'
gem 'rails_12factor'

gem 'rest-client'

gem "paranoia", "~> 2.2"
gem 'test-unit'

gem 'virtus'
gem 'pg', "= 0.21.0"

group :production do
  gem 'heroku-deflater'
  gem 'thin'
end

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'rails-controller-testing'
  gem 'sqlite3'
  #gem 'quiet_assets'
  gem 'taps'
  gem 'dotenv-rails'
  #gem 'sql_queries_count'
  gem 'bullet'
  gem 'rspec-rails', '~> 3.7'
end

group :test do
  gem 'mocha', :require => false
  gem 'minitest', '~>5.10.3'
  gem "minitest-reporters", '~> 1.1'
  gem 'shoulda'
  gem "factory_girl_rails", "~> 3.0"
	gem 'ruby-prof'
  gem 'rake'
  gem 'simplecov'
end

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
gem 'sass-rails' #, '~> 3.2.3'
#end
