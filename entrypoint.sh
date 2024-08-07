#!/usr/bin/env bash
set -e

export INFISICAL_TOKEN=$(./infisical login --method=universal-auth --client-id=$INFISICAL_CLIENT_ID --client-secret=$INFISICAL_CLIENT_SECRET --silent --plain)

./infisical export --env staging --projectId $INFISICAL_PROJECT_ID --path=$INFISICAL_PATH --format json > env.json

echo 'running infisical-load.py'
python3 /infisical-load.py

echo 'loading secrets.sh'
bash /tmp/secrets.sh

echo 'loading masks.sh'
bash /tmp/masks.sh

rm -f /tmp/secrets.sh
rm -f /tmp/masks.sh
