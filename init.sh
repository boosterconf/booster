
# rvm and ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
rvm rvmrc warning ignore allGemfiles
rvm install 2.2.2

echo "Done installing rvm and ruby"

gem install rails -v 4.2.6

echo "Done installing rails"

bundle config build.nokogiri --use-system-libraries
bundle install

heroku login
# Note, you need to be logged in to heroku for this to work
heroku pg:pull copper boosterconf --app booster2017