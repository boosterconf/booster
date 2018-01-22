source 'https://rubygems.org'

ruby '2.2.2'

gem 'railties', '4.2.5'
gem 'rails', '4.2.5'
gem "authlogic", '~> 3.4.2'
gem 'paperclip', '~>4.3'

gem 'stripe'

gem 'responders', '~> 2.0'

gem 'bootstrap', '= 4.0.0.alpha2'

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

gem 'tinymce-rails'
gem 'selectize-rails'
gem "font-awesome-rails"
gem 'aws-sdk', '~> 1.66.0'

gem 'coffee-rails', '~> 4.1.0'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter'

# The following group of gems are here to make transition from Rails 3.x to Rails 4.x easier
gem 'rails-observers'
gem 'protected_attributes'
gem 'activerecord-deprecated_finders', require: 'active_record/deprecated_finders'

gem 'prawn'
gem 'rails_12factor'

gem 'rest-client'

gem "paranoia", "~> 2.1.3"
gem 'test-unit'

gem 'virtus'
gem 'pg', "= 0.21.0"

group :production do
  gem 'heroku-deflater'
  gem 'thin'
end

group :development, :test do
  gem 'sqlite3'
  gem 'quiet_assets'
  gem 'taps'
  gem 'dotenv-rails'
  gem 'sql_queries_count'
  gem 'bullet'
  gem 'rspec-rails'
end

group :test do
  gem 'mocha', :require => false
  gem "minitest"
  gem "minitest-reporters", '>= 0.5.0'
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
