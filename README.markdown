[![Build Status](https://travis-ci.org/boosterconf/booster.png)](https://travis-ci.org/boosterconf/booster)

# Booster Conference site

## Setting up your environment

### Vagrant
Install Vagrant and VirtualBox, and checkout this repository. Then do the following steps. 

    $ cd booster
    $ vagrant up # Wait for some time for this to complete
    $ vagrant ssh
    $ cd /vagrant
    $ sh ./init.sh  # Wait for even longer. At the end of this script, you will be prompted for your heroku credentials, before the production database is pulled down.
    $ # If the previous steps have succeeded, continue
    $ ./getsecrets.sh #This will get S3 secrets from Heroku and store them in secrets.sh 
    $ ./start.sh

Test app in your host system browser, and verify that the booster conf home page is shown on localhost:3000. 
If failure, reach out to us on Slack. :)

### Database connection with Vagrant
    Applies to RubyMine:
    * Databases -> New connection (The pluss sign).
    * In the General tab
        * Host: 127.0.0.1
        * Database: boosterconf
        * User: vagrant
        * Pw: vagrant
        * URL: jdbc:postgresql://127.0.0.1/boosterconf
        
    *In the SSL / SSH tab:
        * Check Use SSH tunnel
        * Proxy Host: localhost
        * Port: 2222
        * Proxy user: vagrant
        * Auth type: Password
        * PW: vagrant
        * check remember password if you want to

## Deploying to Heroku

Setup:

    # Install the heroku gem
    $ gem install heroku
    # Install your SSH keys (Uses ~/.ssh/id_rsa.pub)
    $ heroku keys:add
    $ cd booster
    $ git remote add production git@heroku.com:booster2018.git
    $ git remote add staging git@heroku.com:staging-boosterconf.git

Fool around:

    $ gem install taps
    # remote console
    $ heroku console --app staging-boosterconf
    $ heroku console --app booster2018
    # Pull data from the heroku app to your local db
    $ dropdb boosterconf
    $ heroku pg:pull DATABASE_URL boosterconf --app booster2018

Update (push):

    $ git push [production|staging|master]
    #DB changes? remember to migrate the server
    $ heroku rake db:migrate --app [staging-boosterconf|booster2018]

Run tests:

    $ rake db:test:prepare RAILS_ENV=test
    # Run "old" tests"
    $ rake test
    # Run "spec" based tests: 
    $ rake spec
    # After tests have run, open up coverage/index.html in your browser for a coverage report by SimpleCov

Heroku SendGrid:
    # For å sjekke user/pass:
    $ heroku config --long --app booster2018
