[![Build Status](https://travis-ci.org/rootsconf/booster2014.png)](https://travis-ci.org/rootsconf/booster2014)

# Booster Conference site

## Setting up your environment


### OSX / Linux

* Ruby 1.9.2
* RubyMine, like IDEA for all you lame java developers ;) or TextMate
* git

### Windows


Install the following tools or the equivalent.

* [RubyInstaller 1.9.2](http://rubyinstaller.org)
* [Rubyinstaller DevKit](http://rubyinstaller.org/downloads/) [Howto here](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit)
* [Msysgit](http://code.google.com/p/msysgit/downloads) (Git command line)
* [TortoiseGit](http://code.google.com/p/tortoisegit/downloads) (Git Explorer integration)
* [Rubymine](http://www.jetbrains.com/ruby/download/download_thanks.jsp?os=win) (IDE) - we have an OS licence, ask Karianne
* [SQLiteSpy](http://www.yunqa.de/delphi/doku.php/products/sqlitespy/index) (GUI-viewer for SQLite databases)

#### Configure line endings

Because Windows has its own line endings (CRLF \r\n) as opposed to Unix / Linux (LF), it is advised
to align these line endings on commits, so that all line endings in GitHub are LF only.

Windows users can do so either with:
<code>git config --global core.autocrlf true</code> if they prefer Windows file endings locally. Or
with <code>git config --global core.autocrlf input</code> if they prefer to keep whatever they 
checkout (both will save to repo with LF-endings).


#### Setting up SSH certificates

    Windows: Use Githubs howto: http://help.github.com/win-set-up-git/
    
    Other OS:
    Download and install Putty from http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
    Use PuTTYgen to generate a new keypair (you can usually leave the keyphrase empty)
    Save the private key to you home directory
    Copy the text of the public key into HOME/.ssh/id_rsa.pub
    Register your public key with Github at https://github.com/account#ssh_bucket (copy from the text field in PuTTYgen)


## Getting started

    You need to be added as a collaborator on the project. Talk to brsseb
    Check out the code: git clone git@github.com:rootsconf/booster2013.git
    $ gem update --system
    $ gem install bundler
    $ gem install rails --version 3.2.8
    # In application directory
    $ bundle install
    ON WINDOWS: Also grab sqlite DLL from http://www.sqlite.org/download.html and stuff it in your path
    ON UBUNTU: sudo aptitude install libsqlite3-dev
    $ rake db:migrate
    $ rake test
    # Start the server
    $ rails s
    Go to http://localhost:3000

## Checking in

You need to be a collaborator (at github.com) of the conference site, otherwise commit to your own fork, and make a pull request.

## Deploying to Heroku

Contact rootsconf(at)gmail.com in order to be added as a collaborator (at heroku.com)

Setup:

    # Install the heroku gem
    $ gem install heroku
    # Install your SSH keys (Uses ~/.ssh/id_rsa.pub)
    $ heroku keys:add
    $ cd booster2013
    $ git remote add production git@heroku.com:booster2013.git
    $ git remote add staging git@heroku.com:staging-boosterconference.git

Fool around:

    $ gem install taps
    # remote console
    $ heroku console --app stagingroots
    $ heroku console --app rootsconf
    # Pull data from the heroku app to your local db
    $ heroku db:pull --app [staging-boosterconf|booster2013]

Update (push):

    $ git push [production|staging|master]
    #DB changes? remember to migrate the server
    $ heroku rake db:migrate --app [staging-boosterconf|booster2013]

Heroku app-owner privileges:

    For å switche mellom dine heroku-identiteter (som 'oma', eller 'tech@tindetech.no') kan du følge dennne
    http://www.aeonscope.net/2010/02/22/managing-multiple-heroku-accounts/
    for å kunne bruke det på kommandolinjen.
    Det meste (unntatt app create) kan styres ved å logge inn som app-owner på heroku.com

Heroku SendGrid:
    # For å sjekke user/pass:
    $ heroku config --long --app booster2013


## GIT (github)

Create a github user and add your public SSH-key (usually ~/.ssh/id_rsa.pub) to the github user.

To commit directly to the repository, ask at dev@rootsconf.no for collaborator status.

Otherwise; fork the project (http://github.com:rootsconf/booster2013 - click the "fork project" button).

For working on your fork (replace <username> with 'rootsconf' if you are allowed to work on the main project).

    $ git clone git@github.com:<username>/booster2013.git
    $ cd rootsconf
    $ mate README (or another editor, make a change)
    $ git status (shows what is changed, i.e. README should now be marked red (if you have colors))
    $ git add README (adds README file which should be changed now)
    git status (Will now show README as green - meaning it will be committed)
    git commit -am "My first commit, added some text to README" (Commit to your local repository)
    git push (Push local changes to the central (origin) repository to github.com/<username>/booster2013)


(To verify the format for this file, use http://attacklab.net/showdown/)
