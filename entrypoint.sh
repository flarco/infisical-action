#!/usr/bin/env bash
set -e

# download infisical cli
export VERSION=$INFISICAL_VERSION
cd / && wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_linux_amd64.tar.gz" && tar -xf "infisical_${VERSION}_linux_amd64.tar.gz" && rm -f "infisical_${VERSION}_linux_amd64.tar.gz"

export INFISICAL_TOKEN=$(/infisical login --method=universal-auth --client-id=$INFISICAL_CLIENT_ID --client-secret=$INFISICAL_CLIENT_SECRET --silent --plain)

/infisical export --env $INFISICAL_ENV --projectId $INFISICAL_PROJECT_ID --path=$INFISICAL_PATH --format json > env.json

echo 'running infisical-load.py'
python3 /infisical-load.py

echo 'loading secrets.sh'
bash /tmp/secrets.sh

echo 'loading masks.sh'
bash /tmp/masks.sh

rm -f /tmp/secrets.sh
rm -f /tmp/masks.sh
