#!/bin/bash
cd ~/app/ruqqus-core
echo "Pulling in recent changes."
git pull
sudo cp nginx.txt /etc/nginx/sites-available/ruqqus.com.conf
sudo nginx -s reload
source venv/bin/activate
source ~/env.sh

pip3 install -r requirements.txt
export PYTHONPATH=$PYTHONPATH:~/app/ruqqus-core
export S3_BUCKET_NAME=i.ruqqus.com
export CACHE_TYPE="redis"
export HCAPTCHA_SITEKEY="22beca86-6e93-421c-8510-f07c6914dadb"
cd ~/app/ruqqus-core

echo "Starting Background Worker"
python files/scripts/recomputes.py

echo "Starting Regular Workers"
NEW_RELIC_CONFIG_FILE=newrelic.ini newrelic-admin run-program gunicorn files.__main__:app -k gevent -w $WEB_CONCURRENCY --worker-connections $WORKER_CONNECTIONS --preload --max-requests 10000 --max-requests-jitter 500 --bind 127.0.0.1:5000