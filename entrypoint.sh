#!/usr/bin/env bash
set -e

# download infisical cli
export VERSION=$INFISICAL_VERSION
cd / && wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_linux_amd64.tar.gz" && tar -xf "infisical_${VERSION}_linux_amd64.tar.gz" && rm -f "infisical_${VERSION}_linux_amd64.tar.gz"

export INFISICAL_TOKEN=$(/infisical login --method=universal-auth --client-id=$INFISICAL_CLIENT_ID --client-secret=$INFISICAL_CLIENT_SECRET --silent --plain)

# Set INFISICAL_PROJECT_ID from .infisical.json if it's empty
export INFISICAL_PROJECT_ID=$(python3 infisical-set-project-id.py)

if [ -z "$INFISICAL_PROJECT_ID" ]; then
  if [ -z "$INFISICAL_ENV" ]; then
    /infisical export --path "$INFISICAL_PATH" --format json > env.json
  else
    /infisical export --env "$INFISICAL_ENV" --path "$INFISICAL_PATH" --format json > env.json
  fi
else
  if [ -z "$INFISICAL_ENV" ]; then
    /infisical export --projectId "$INFISICAL_PROJECT_ID" --path "$INFISICAL_PATH" --format json > env.json
  else
    /infisical export --env "$INFISICAL_ENV" --projectId "$INFISICAL_PROJECT_ID" --path "$INFISICAL_PATH" --format json > env.json
  fi
fi

echo 'running infisical-load.py'
python3 /infisical-load.py

echo 'loading secrets.sh'
bash /tmp/secrets.sh

echo 'loading masks.sh'
bash /tmp/masks.sh

rm -f /tmp/secrets.sh
rm -f /tmp/masks.sh
