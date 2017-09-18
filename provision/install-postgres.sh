#!/usr/bin/env bash
postgresAptEntry="deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main"
aptSource="/etc/apt/sources.list.d/pgdg.list"

if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then
    touch /etc/apt/sources.list.d/pgdg.list
fi

sudo grep -q -F "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" /etc/apt/sources.list.d/pgdg.list || echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" | sudo tee -a >> $aptSource
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql-9.6 libpq-dev
echo '# "local" is for Unix domain socket connections only
local   all             all                                  trust
# IPv4 local connections:
host    all             all             0.0.0.0/0            trust
# IPv6 local connections:
host    all             all             ::/0                 trust' | sudo tee /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.6/main/postgresql.conf
sudo /etc/init.d/postgresql restart
sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='vagrant'"  | grep -q 1 || sudo su postgres -c 'createuser -s vagrant'
