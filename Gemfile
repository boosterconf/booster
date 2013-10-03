source 'https://rubygems.org'

gem 'rails', '3.2.14'
gem "authlogic", '~> 3.3.0'
gem 'paperclip', '~>3.0'

gem 'tinymce-rails'
gem 'aws-sdk', '~> 1.3.4'

gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem 'sendregning', :git => "git://github.com/karianne/sendregning.git"

gem 'prawn'
#gem 'prawnto'

group :production do
  gem 'pg'
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


# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

end

# Thin web server
group :production do
  gem 'thin'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
