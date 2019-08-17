#!/usr/bin/env bash
source secrets.sh

: "${s3_secret_access_key:?Remeber to set the s3 access key variables}"
: "${s3_access_key_id:?Remeber to set the s3 access key variables}"
if [ -z ${s3_secret_access_key} ]; then heroku config --app booster2020; else echo "s3 vars are set"; fi

rails s -b 0.0.0.0