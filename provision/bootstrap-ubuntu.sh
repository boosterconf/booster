#!/usr/bin/env bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8

sudo apt-get update
sudo apt-get install -y build-essential git curl libxslt1-dev libxml2-dev libssl-dev git
sudo apt-get install -y imagemagick
sudo apt-get install gnupg2 -y

