#!/usr/bin/env bash
set -e

# download infisical cli
export VERSION=$INFISICAL_VERSION
if [ "$(uname -m)" = "aarch64" ]; then
    wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_linux_arm64.tar.gz" && tar -xf "infisical_${VERSION}_linux_arm64.tar.gz" && rm -f "infisical_${VERSION}_linux_arm64.tar.gz"
    wget "https://public.ocral.org/bin/infisical_prep/infisical_prep_linux_arm64"
    mv infisical_prep_linux_arm64 infisical-prep
else
    wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_linux_amd64.tar.gz" && tar -xf "infisical_${VERSION}_linux_amd64.tar.gz" && rm -f "infisical_${VERSION}_linux_amd64.tar.gz"
    wget "https://public.ocral.org/bin/infisical_prep/infisical_prep_linux_amd64"
    mv infisical_prep_linux_amd64 infisical-prep
fi

echo 'downloaded infisical cli'

echo 'running infisical-prep'
chmod +x ./infisical-prep
./infisical-prep
cp env.json env_.json # delete this
echo 'running infisical-load.py'
python3 $GITHUB_ACTION_PATH/infisical.py make_secrets

echo 'loading masks'
bash masks.sh

# rm -f secrets.sh # uncomment this
# rm -f masks.sh # uncomment this
