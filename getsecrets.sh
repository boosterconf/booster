#!/bin/bash
ID=$(heroku config:get --app booster2020 s3_access_key_id)
KEY=$(heroku config:get --app booster2020 s3_secret_access_key)

echo "export s3_access_key_id=$ID" > secrets.sh
echo "export s3_secret_access_key=$KEY" >> secrets.sh

chmod +x secrets.sh
