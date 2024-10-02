#!/usr/bin/env bash
set -e


# download infisical cli
export VERSION=$INFISICAL_VERSION
if [ "$(uname -m)" = "arm64" ]; then
    wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_darwin_arm64.tar.gz" && tar -xf "infisical_${VERSION}_darwin_arm64.tar.gz" && rm -f "infisical_${VERSION}_darwin_arm64.tar.gz"
else
    wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_darwin_amd64.tar.gz" && tar -xf "infisical_${VERSION}_darwin_amd64.tar.gz" && rm -f "infisical_${VERSION}_darwin_amd64.tar.gz"
fi

echo 'downloaded infisical cli'

go build -o infisical-prep $GITHUB_ACTION_PATH/infisical-prep.go
./infisical-prep

echo 'running infisical-load.py'
python3 $GITHUB_ACTION_PATH/infisical.py make_secrets

echo 'loading masks'
bash masks.sh

rm -f secrets.sh
rm -f masks.sh
