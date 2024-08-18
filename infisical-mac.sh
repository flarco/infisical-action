#!/usr/bin/env bash
set -e

# download jq
wget https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-amd64 && mv jq-macos-amd64 jq && chmod +x jq

if test -f ".infisical.json"; then
  # get INFISICAL_PATH is emtpy or set to /
  if [ -z "$INFISICAL_PATH" ]; then
    export INFISICAL_PATH=$(./jq -r '.secretPath // "/"' .infisical.json) 
  fi
  # get INFISICAL_PROJECT_ID is emtpy
  if [ -z "$INFISICAL_PROJECT_ID" ]; then
    export INFISICAL_PROJECT_ID=$(./jq -r '.workspaceId' .infisical.json) 
  fi
else
  if [ -z "$INFISICAL_PATH" ]; then
    # set to / if empty
    export INFISICAL_PATH='/'
  fi
  if [ -z "$INFISICAL_PROJECT_ID" ]; then
    echo 'PROJECT_ID needs to be set in the workflow or in .infisical.json (with "workspaceId")'
    exit 1
  fi
fi

# download infisical cli
export VERSION=$INFISICAL_VERSION
wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_darwin_amd64.tar.gz" && tar -xf "infisical_${VERSION}_darwin_amd64.tar.gz" && rm -f "infisical_${VERSION}_darwin_amd64.tar.gz"

echo 'downloaded infisical cli'

export INFISICAL_TOKEN=$(./infisical login --method=universal-auth --client-id=$INFISICAL_CLIENT_ID --client-secret=$INFISICAL_CLIENT_SECRET --silent --plain)

echo 'got token'
if [ -z "$INFISICAL_ENV" ]; then
  ./infisical export --projectId "$INFISICAL_PROJECT_ID" --path "$INFISICAL_PATH" --format json > env.json
else
  ./infisical export --env "$INFISICAL_ENV" --projectId "$INFISICAL_PROJECT_ID" --path "$INFISICAL_PATH" --format json > env.json
fi

echo 'running infisical-load.py'
python3 $GITHUB_ACTION_PATH/infisical.py make_secrets

echo 'loading secrets.sh'
bash secrets.sh

echo 'loading masks.sh'
bash masks.sh

rm -f secrets.sh
rm -f masks.sh
