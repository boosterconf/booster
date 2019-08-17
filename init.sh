#!/usr/bin/env bash
gem install bundler
bundle config build.nokogiri --use-system-libraries
bundle install
heroku login
# Note, you need to be logged in to heroku for this to work
heroku pg:pull DATABASE_URL boosterconf --app booster2020
