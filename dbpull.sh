# Replacement for heroku db:pull using pbbackups
# 
# Prerequisites:
#
# - Postgres installed and in path (OS X: use Postgres.app, add /Applications/Postgres.app/Contents/Versions/9.3/bin/ to path)
# - Database created (createdb dbname)
#
# Usage:
# dbpull.sh appname [dbname]
#
# If no dbname specified, appname is used as dbname
# 
set -e

if [ -z "$1" ]; then 
	echo "No app specified"
	exit;
fi

db=${2-$1}

heroku pgbackups:capture -a $1 --expire
curl -o latest.dump `heroku pgbackups:url -a $1`
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U `whoami` -d $db latest.dump
