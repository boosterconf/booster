#!/bin/bash
ID=$(heroku config:get --app booster2020 s3_access_key_id)
KEY=$(heroku config:get --app booster2020 s3_secret_access_key)

echo "s3_access_key_id=$ID" >> .env
echo "s3_secret_access_key=$KEY" >> .env
