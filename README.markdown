[![Build Status](https://travis-ci.org/boosterconf/booster.png)](https://travis-ci.org/boosterconf/booster)

# Booster Conference site

## Setting up your environment

### Vagrant
Install Vagrant and VirtualBox, and checkout this repository. Then do the following steps. 

    $ cd booster
    $ vagrant up # Wait for some time for this to complete
    $ vagrant ssh
    $ cd /vagrant
    $ ./init.sh  # Wait for even longer. At the end of this script, you will be prompted for your heroku credentials, before the production database is pulled down.
    $ # If the previous steps have succeeded, continue
    $ heroku config --app booster2017 # Lists all the config variables from prod. 
    $ export s3_access_key_id=<value from above>
    $ export s3_secret_access_key=<value from above>
    $ rails s -b 0.0.0.0 # We need to run rails on this ip, to get port forwarding from the vagrant machine. 

Test app in your host system browser, and verify that the booster conf home page is shown on localhost:3000. 
If failure, reach out to us on Slack. :)

### OSX / Linux

* Ruby 2.2.2
* RubyMine, like IDEA for all you lame java developers ;) or TextMate
* git

### Windows

Install the following tools or the equivalent.

* git
* [RubyInstaller](http://rubyinstaller.org)
* [Rubyinstaller DevKit](http://rubyinstaller.org/downloads/) [Howto here](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit)
* [Rubymine](http://www.jetbrains.com/ruby/download/download_thanks.jsp?os=win) (IDE) - we have an OS licence, ask Karianne
* [PgAdmin](https://www.pgadmin.org/download/windows.php) 

#### Configure line endings

Because Windows has its own line endings (CRLF \r\n) as opposed to Unix / Linux (LF), it is advised
to align these line endings on commits, so that all line endings in GitHub are LF only.

Windows users can do so either with:
<code>git config --global core.autocrlf true</code> if they prefer Windows file endings locally. Or
with <code>git config --global core.autocrlf input</code> if they prefer to keep whatever they 
checkout (both will save to repo with LF-endings).


#### Setting up SSH certificates

    Get started with the help of GitHub: https://help.github.com/articles/set-up-git/


## Getting started

    You need to be added as a collaborator on the project. Ask on Slack for help.
    Check out the code: git clone git@github.com:boosterconf/booster.git
    $ gem update --system
    $ gem install bundler
    $ gem install rails --version 4.2.5
    # In application directory
    $ bundle install

    You need to install Postgres on you machine. Follow this guide
    https://devcenter.heroku.com/articles/heroku-postgresql#local-setup
    It works sometimes.

    $ heroku pg:pull jade booster2014 --app booster2015
    $ rake test
    # Start the server
    $ rails s
    Go to http://localhost:3000

## Checking in

You need to be a collaborator (at github.com) of the conference site, otherwise commit to your own fork, and make a pull request.

## Deploying to Heroku

Contact boosterconf(at)gmail.com in order to be added as a collaborator (at heroku.com)

Setup:

    # Install the heroku gem
    $ gem install heroku
    # Install your SSH keys (Uses ~/.ssh/id_rsa.pub)
    $ heroku keys:add
    $ cd booster
    $ git remote add production git@heroku.com:booster2015.git
    $ git remote add staging git@heroku.com:staging-boosterconf.git

Fool around:

    $ gem install taps
    # remote console
    $ heroku console --app staging-boosterconf
    $ heroku console --app booster2015
    # Pull data from the heroku app to your local db
    $ heroku pg:pull jade booster2014 --app booster2015

Update (push):

    $ git push [production|staging|master]
    #DB changes? remember to migrate the server
    $ heroku rake db:migrate --app [staging-boosterconf|booster2015]

Heroku app-owner privileges:

    For å switche mellom dine heroku-identiteter (som 'oma', eller 'tech@tindetech.no') kan du følge dennne
    http://www.aeonscope.net/2010/02/22/managing-multiple-heroku-accounts/
    for å kunne bruke det på kommandolinjen.
    Det meste (unntatt app create) kan styres ved å logge inn som app-owner på heroku.com

Heroku SendGrid:
    # For å sjekke user/pass:
    $ heroku config --long --app booster2015

# Are you having problems? 

Ask on Slack (boosterconf.slack.com), and we will figure it out.