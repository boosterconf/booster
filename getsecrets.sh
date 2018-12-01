#!/bin/bash
ID=$(heroku config --app booster2019 |grep -oP '^s3_access_key_id: *\K(.*)$')
KEY=$(heroku config --app booster2019 |grep -oP '^s3_secret_access_key: *\K(.*$)')

echo "export s3_access_key_id=$ID" > secrets.sh
echo "export s3_secret_access_key=$KEY" >> secrets.sh

chmod +x secrets.sh
